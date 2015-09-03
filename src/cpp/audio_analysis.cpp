#include <iostream>
#include <exception>
#include <essentia/essentiautil.h>
#include <essentia/algorithmfactory.h>
#include <essentia/streaming/algorithms/poolstorage.h>
#include <essentia/scheduler/network.h>
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <cmath>
#include <limits>

using namespace std;
using namespace essentia;
using namespace essentia::streaming;
using namespace essentia::scheduler;

#define IN_BUF_SIZE 4096
#define N_DESCRIPTORS 2
#define N_PROCESSING_STREAMS 2

// Real is typedef'd to float
float in_buf[N_PROCESSING_STREAMS * IN_BUF_SIZE];
float out_buf[N_PROCESSING_STREAMS * N_DESCRIPTORS];
Network *networks[N_PROCESSING_STREAMS];

void init_cpp(Network **network, Real *input_addr, Real *out_addr);

// These functions will be exported to use by javascript.
extern "C" {
    float *in_buf_address(int index_processing_stream) {
        return in_buf + index_processing_stream * IN_BUF_SIZE;
    }

    float *out_buf_address(int index_processing_stream) {
        return out_buf + index_processing_stream * N_DESCRIPTORS;
    }

    void process(int index_processing_stream) {
        networks[index_processing_stream]->runStep();
    }
    void init() {
        essentia::init();
	for(int i=0; i<N_PROCESSING_STREAMS; i++)
            init_cpp(&networks[i], in_buf_address(i), out_buf_address(i));
    }
    void quit() {
        essentia::shutdown();
	for(int i=0; i<N_PROCESSING_STREAMS; i++)
          delete networks[i];
    }
}

class BufferReader : public Algorithm {
protected:
    Real *buf;
    int bufSize;
    Source<Real> _output;

public:
    BufferReader(Real *_buf, int _bufSize) : Algorithm(), buf(_buf), bufSize(_bufSize) {
        setName("BufferReader");
        declareOutput(_output, bufSize, "output", "the output read from the buffer");
        _output.setBufferType(BufferUsage::forAudioStream);
    }
    AlgorithmStatus process() {
        acquireData();
        vector<Real> &ot = _output.tokens();
        for(int i=0; i<bufSize; i++)
            ot[i] = buf[i];
        releaseData();
        return OK;
    }

    void declareParameters() {
    }

    static const char* name;
    static const char* description;

    void configure() {
    }

};

class BufferWriter : public Algorithm {
 protected:
    Real *buf;
    int bufSize;
    Sink<Real> _input;

 public:
    BufferWriter(Real *_buf, int _bufSize) : Algorithm(), buf(_buf), bufSize(_bufSize) {
        setName("BufferWriter");
        declareInput(_input, bufSize, "input", "the input that will be written to the buffer");
    }
    AlgorithmStatus process() {
        AlgorithmStatus status = acquireData();
        if(status != OK) {
            return NO_INPUT;
        }
        if(_input.available() == 0)
            return NO_INPUT;
        const vector<Real> &it = _input.tokens();
        for(int i=0; i<bufSize; i++)
            buf[i] = it[i];
        releaseData();
        return OK;
    }

    void declareParameters() {
    }

    static const char* name;
    static const char* description;

    void configure() {
    }

};

class PostProcessor : public Algorithm {
  protected:
    Sink<Real> _in_pitch;
    Sink<Real> _in_pitch_confidence;
    Sink<Real> _in_energy;
    Source<Real> _out_pitch;
    Source<Real> _out_energy;
  public:
    PostProcessor() : Algorithm() {
        setName("PostProcessor");
#define DECL_IN(what) declareInput(_in_##what, 1, #what, "the " #what " to process")
	DECL_IN(pitch);
	DECL_IN(pitch_confidence);
	DECL_IN(energy);
#undef DECL_IN
#define DECL_OUT(what) declareOutput(_out_##what, 1, #what, "the processed " #what)
	DECL_OUT(pitch);
	DECL_OUT(energy);
#undef DECL_OUT
    }

    AlgorithmStatus process() {
        AlgorithmStatus status = acquireData();
        if(status != OK) {
            return NO_INPUT;
        }

	Real pitch = 12 * log2(_in_pitch.tokens()[0] / 440.);

	if(_in_pitch_confidence.tokens()[0] < 0.8)
	    _out_pitch.tokens()[0] = std::numeric_limits<Real>::quiet_NaN();
	else
	    _out_pitch.tokens()[0] = pitch;

	_out_energy.tokens()[0] = 3.0 * _in_energy.tokens()[0];

        releaseData();
        return OK;
    }

    void declareParameters() {
    }

    static const char* name;
    static const char* description;

    void configure() {
    }
};

// By altering the input parameters to this function, you can make N analyzing
// networks which are independent from each other.
void init_cpp(Network **network, Real *input_addr, Real *out_addr)
{
    Real sampleRate = 44100.0;
    int hopSize = 2048;
    int frameSize = 4096;

    // audio -> frameCutter -> Spectrum -> PitchYinFFT
    AlgorithmFactory &factory = streaming::AlgorithmFactory::instance();
    Algorithm *inp = new BufferReader(input_addr, IN_BUF_SIZE);
    Algorithm *frameCutter = factory.create("FrameCutter",
                                            "frameSize", frameSize,
                                            "hopSize", hopSize,
                                            "silentFrames", "noise");
    Algorithm *rms = factory.create("RMS");
    Algorithm *windowing = factory.create("Windowing",
                                          "type", "hann");
    Algorithm *spectrum = factory.create("Spectrum");
    Algorithm *pitch = factory.create("PitchYinFFT");

    Algorithm *post_process = new PostProcessor();

    Algorithm *pitch_writer = new BufferWriter(&out_addr[0], 1);
    Algorithm *energy_writer = new BufferWriter(&out_addr[1], 1);

    inp->output("output") >> frameCutter->input("signal");

    frameCutter->output("frame") >> windowing->input("frame");
    windowing->output("frame") >> spectrum->input("frame");
    spectrum->output("spectrum") >> pitch->input("spectrum");
    pitch->output("pitchConfidence") >> post_process->input("pitch_confidence");
    pitch->output("pitch") >> post_process->input("pitch");

    frameCutter->output("frame") >> rms->input("array");
    rms->output("rms") >> post_process->input("energy");

    post_process->output("pitch") >> pitch_writer->input("input");
    post_process->output("energy") >> energy_writer->input("input");

    *network = new Network(inp);
    (*network)->runPrepare();
}

int main() {
    essentia::init();
    init_cpp(&networks[0], in_buf_address(0), out_buf_address(0));
    for(int i=0; i<12; i++)
        networks[0]->runStep();
    essentia::shutdown();
    delete networks[0];
    return 0;
}
