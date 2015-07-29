LIB_DIR=/Users/adria/Software/emsdk_portable/emscripten/incoming/system/local/lib

.PHONY: all clean

all: audio_analysis.js

audio_analysis.js: audio_analysis.bc
	emcc -Oz audio_analysis.bc ${LIB_DIR}/libessentia.a ${LIB_DIR}/libfftw3f.a \
		 -s EXPORTED_FUNCTIONS="['_in_buf_address', '_out_buf_address', '_confidence_address', '_process', '_init', '_quit']" \
		 -s DISABLE_EXCEPTION_CATCHING=0 \
		 -o audio_analysis.js

audio_analysis.bc: audio_analysis.cpp
	emcc -Oz -c audio_analysis.cpp -o audio_analysis.bc

clean:
	rm audio_analysis.bc audio_analysis.js.mem audio_analysis.js

