#include <iostream>
#include <exception>
#include <essentia/essentiautil.h>
#include <essentia/algorithmfactory.h>
#include <essentia/streaming/algorithms/poolstorage.h>
#include <essentia/scheduler/network.h>
#include <cstdlib>
#include <cstring>
#include <cstdio>

using namespace std;
using namespace essentia;
using namespace essentia::streaming;
using namespace essentia::scheduler;

#define IN_BUF_SIZE 4096

// Real is typedef'd to float
float in_buf[IN_BUF_SIZE];
Network *network;

void init_cpp();

// These functions will be exported to use by javascript.
extern "C" {
    float *in_buf_address() {
        return in_buf;
    }

#define OUTPUT(x) float x; float * x##_address () { return & x ; }
    OUTPUT(pitch)
    OUTPUT(energy)
    OUTPUT(confidence)
#undef OUTPUT

    void process() {
        network->runStep();
    }
    void init() {
        init_cpp();
    }
    void quit() {
        essentia::shutdown();
        delete network;
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

template<typename T>
class StreamFork : public Algorithm {
  protected:
    Sink<T> _input;
    vector<Source<T> *> _outputs;
  public:
    StreamFork(int n) : Algorithm() {
        setName("StreamFork");
        declareInput(_input, "input", "the input to be copied to the N outputs");
	char description[256];
	char name[16];
        for(int i=0; i<n; i++) {
	    snprintf(name, 16, "out%d", i);
	    snprintf(description, 256, "the %d'th output the input will be copied to", i);
            _outputs.push_back(new Source<T>());
            declareOutput(*_outputs[i], string(name), string(description));
        }
    }

    ~StreamFork() {
	for(auto out = _outputs.begin(); out != _outputs.end(); out++) {
            delete *out;
        }
    }

    AlgorithmStatus process() {
	int nframes = min(_input.available(),
                          _input.buffer().bufferInfo().maxContiguousElements);
	nframes = max(nframes, 1);

	if(!_input.acquire(nframes))
	    return NO_INPUT;

	for(auto out = _outputs.begin(); out != _outputs.end(); out++) {
	    if((*out)->acquire(nframes))
		return NO_OUTPUT;
	    fastcopy(&(*out)->firstToken(), &_input.firstToken(), nframes);
	    (*out)->release(nframes);
	}

	_input.release(nframes);
        return OK;
    }

    void declareParameters() {
    }

    static const char* name;
    static const char* description;

    void configure() {
    }
};

void init_cpp()
{
    essentia::init();

    Real sampleRate = 44100.0;
    int hopSize = IN_BUF_SIZE;
    int frameSize = hopSize * 2;

    // audio -> frameCutter -> Spectrum -> PitchYinFFT
    AlgorithmFactory &factory = streaming::AlgorithmFactory::instance();
    Algorithm *inp = new BufferReader(in_buf, IN_BUF_SIZE);
    Algorithm *frameCutter = factory.create("FrameCutter",
                                            "frameSize", frameSize,
                                            "hopSize", hopSize,
                                            "silentFrames", "noise");
    Algorithm *fork = new StreamFork<vector<Real> >(2);
    Algorithm *rms = factory.create("RMS");
    Algorithm* windowing = factory.create("Windowing",
                                          "type", "hann");
    Algorithm *spectrum = factory.create("Spectrum");
    Algorithm *pitch = factory.create("PitchYinFFT");

#define WRITER(x) Algorithm * x##_writer = new BufferWriter(x##_address(), 1)
    WRITER(pitch);
    WRITER(confidence);
    WRITER(energy);
#undef WRITER

    inp->output("output") >> frameCutter->input("signal");
    frameCutter->output("frame") >> fork->input("input");

    fork->output("out0") >> windowing->input("frame");
    windowing->output("frame") >> spectrum->input("frame");
    spectrum->output("spectrum") >> pitch->input("spectrum");
    pitch->output("pitchConfidence") >> confidence_writer->input("input");
    pitch->output("pitch") >> pitch_writer->input("input");

    fork->output("out1") >> rms->input("array");
    rms->output("rms") >> energy_writer->input("input");

    network = new Network(inp);
    network->runPrepare();
}

int main() {
    init_cpp();
    for(int i=0; i<12; i++)
        network->runStep();
    return 0;
}
