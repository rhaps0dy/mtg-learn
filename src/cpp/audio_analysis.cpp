#include <iostream>
#include <exception>
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
#define OUT_BUF_SIZE 1

// Real is typedef'd to float
float in_buf[IN_BUF_SIZE];
Network *network;
float out_buf[OUT_BUF_SIZE];
float confidence;

void init_cpp();

// These functions will be exported to use by javascript.
extern "C" {
    float *in_buf_address() {
        return in_buf;
    }
    float *out_buf_address() {
        return out_buf;
    }
    float *confidence_address() {
	return &confidence;
    }
    void process() {
        network->runStep();
    }
    int main() {
        init_cpp();
        return 0;
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
    Algorithm* windowing = factory.create("Windowing",
                                          "type", "hann");
    Algorithm *spectrum = factory.create("Spectrum");
    Algorithm *pitch = factory.create("PitchYinFFT");
    Algorithm *out = new BufferWriter(out_buf, OUT_BUF_SIZE);
    Algorithm *confWriter = new BufferWriter(&confidence, 1);

    inp->output("output") >> frameCutter->input("signal");
    frameCutter->output("frame") >> windowing->input("frame");
    windowing->output("frame") >> spectrum->input("frame");
    spectrum->output("spectrum") >> pitch->input("spectrum");
    pitch->output("pitchConfidence") >> confWriter->input("input");
    pitch->output("pitch") >> out->input("input");

    network = new Network(inp);
    network->runPrepare();
}
