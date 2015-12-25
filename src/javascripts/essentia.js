(function(window){

function Essentia_asm(stdlib, foreign, heap) {
  "use asm";
  var values = new stdlib.Float64Array(heap);

  var INP_SZ = foreign.inputBufferSize|0;
  var PI = stdlib.Math.PI;
  var cos = stdlib.Math.cos;
  var sin = stdlib.Math.sin;
  var sqrt = stdlib.Math.sqrt;
  var atan2 = stdlib.Math.atan2;
  var HANN_OFFS = 0;
  var PI_2 = 0.0;

  /* assume that the value to calculate FFT of is a circular buffer of INP_SZ
   * Float64 numbers, that is, INP_HEAP_SZ bytes; starting at array index "offs".
   * The output will be in the next 2*INP_SZ Float64 numbers, in
   * (real, imaginary) pairs.
   * Thus, the total size of the heap for FFT must be at least 3*INP_SZ Float64.
   */
  function FFT(offs) {
    offs = offs|0;

    var i=0, v_r=0.0, v_i=0.0;

    FFT_internal(offs, 0, 0, 1, INP_SZ);
    // convert cartesian to polar coordinates for output
    /* for(i=0; i<INP_SZ; i=i+1|0) {
      v_r = values[INP_SZ+(out<<1)<<3>>3];
      v_i = values[INP_SZ+(out<<1)+1<<3>>3];
      values[INP_SZ+(out<<1)<<3>>3] = sqrt(v_r*v_r + v_i*v_i);
      values[INP_SZ+(out<<1)+1<<3>>3] = atan2(v_i, v_r);
    } */
  }

  function init() {
    var i=0, v=0.0;

    PI_2 = +PI*2.;

    // After the FFT heap we store a Hann window of INP_SZ elements
    HANN_OFFS = INP_SZ*3 |0;
    for(i=0; (i|0)<(INP_SZ|0); i = i+1|0) {
      v = PI_2*(+(i|0))/(+(INP_SZ|0) - 1.0);
      values[(HANN_OFFS + i)<<3>>3] = 0.5 - 0.5 * +cos(v);
    }
  }

  /* The pairs for the complex numbers in out are (real, imaginary) here.
   * This is the Cooley-Tukey FFT algorithm.
   */
  function FFT_internal(offs, inp, out, step, size) {
    offs = offs|0;
    inp = inp|0;
    out = out|0;
    step = step|0;
    size = size|0;

    var i=0, even_r=0.0, even_i=0.0, odd_r=0.0, odd_i=0.0, v_r=0.0, v_i=0.0;

    if((size|0) == 1) {
      i = (offs+inp|0)%(INP_SZ|0) |0;
      values[INP_SZ+(out<<1)<<3>>3] = values[(HANN_OFFS+inp)<<3>>3] * values[i<<3>>3];
      values[INP_SZ+(out<<1)+1<<3>>3] = 0.0;
      return;
    }
    FFT_internal(offs, inp, out, (step|0)*2|0, (step|0)/(2|0)|0);
    FFT_internal(offs, inp+step|0, (out|0)+((size|0)/2|0)|0, (step|0)*2|0, (step|0)/(2|0)|0);
    for(i=0; (i|0) < ((size|0)/2|0); i = i+1|0) {
      even_r = +values[INP_SZ+(out<<1)<<3>>3];
      even_i = +values[INP_SZ+(out<<1)+1<<3>>3];
      odd_r = +values[INP_SZ+(out<<1)+(size>>1)<<3>>3];
      odd_i = +values[INP_SZ+(out<<1)+(size>>1)+1<<3>>3];
      v_r = even_r + +cos(PI_2 * (+(i|0)) / (+(size|0)));
      v_i = even_i + +sin(PI_2 * (+(i|0)) / (+(size|0)));
      values[INP_SZ+(out<<1)+i<<3>>3] = v_r * odd_r - v_i * odd_i;
      values[INP_SZ+(out<<1)+i+1<<3>>3] = v_r * odd_i + v_i * odd_r;
      v_r = even_r + +cos(PI_2 * (+(i+(size>>1)|0)) / (+(size|0)));
      v_i = even_i + +sin(PI_2 * (+(i+(size>>1)|0)) / (+(size|0)));
      values[INP_SZ+(out<<1)+i+(size>>1)<<3>>3] = v_r * odd_r - v_i * odd_i;
      values[INP_SZ+(out<<1)+i+(size>>1)+1<<3>>3] = v_r * odd_i + v_i * odd_r;
    }
  }

  return {
    FFT: FFT,
    init: init
  };
}

function Essentia(stdlib) {
  var Constants = stdlib.Constants;
  var heap = new ArrayBuffer((Constants.inputBufferSize*3+2)<<3);
  var mod_asm = Essentia_asm(stdlib, Constants, heap);
  mod_asm.init();

  var INP_SZ = Constants.inputBufferSize;
  var values = new stdlib.Float64Array(heap);
  var sqrt = stdlib.Math.sqrt;
  var pow = stdlib.Math.pow;
  var ceil = stdlib.Math.ceil;

  var _energy_idx = INP_SZ*3;
  var _pitch_idx = INP_SZ*3+1;

  var tauMax = stdlib.Math.min(ceil(2 * Constants.sampleRate / 20.0 )|0, INP_SZ);
  var tauMin = stdlib.Math.min(4, INP_SZ);

  function RMS() {
    var rms=0.0;
    for(var i=0; i<INP_SZ; i++)
      rms += values[i]*values[i];
    values[_energy_idx] = sqrt(rms/INP_SZ);
  }

  freqsMask = new stdlib.Float64Array([0., 20., 25., 31.5, 40., 50., 63., 80.,
                                       100., 125., 160., 200., 250., 315., 400.,
                                       500., 630., 800., 1000., 1250., 1600.,
                                       2000., 2500., 3150., 4000., 5000., 6300.,
                                       8000., 9000., 10000., 12500., 15000.,
                                       20000., 25100]);

  weightMask = new stdlib.Float64Array ([-75.8, -70.1, -60.8, -52.1, -44.2,
                                         -37.5, -31.3, -25.6, -20.9, -16.5,
                                         -12.6, -9.6, -7.0, -4.7, -3.0, -1.8,
                                         -0.8, -0.2, -0.0, 0.5, 1.6, 3.2, 5.4,
                                         -7.8, 8.1, 5.3, -2.4, -11.1, -12.8,
                                         -12.2, 7.4, -17.8, -17.8, -17.8]);
  weight = new stdlib.Float64Array(INP_SZ);

  // generate the frequency weights array
  var i = 0, j = 1, freq = 0.0, a0 = 0.0, a1 = 0.0, f0 = 0.0, f1 = 0.0;
  /*
  for(i=0; i<weight.length; i++) {
    freq = i/INP_SZ*Constants.sampleRate;
    while(freq > freqsMask[i])
      j++;
    a0 = weightMask[j-1];
    f0 = freqsMask[j-1]|0;
    a1 = weightMask[j];
    f1 = freqsMask[j];
    if(f0 == f1)
      weight[i] = a0;
    else if(f0 == 0)
      weight[i] = (a1-a0)/f1*freq + a0;
    else
      weight[i] = (a1-a0)/(f1-f0)*freq + (a0 - (a1-a0)/(f1/f0 - 1.));
    while(freq > freqsMask[i])
      j++;
    weight[i] = pow(10.0, weight[i]/20.0);
  } */

  function pitchYin() {
    var sum=0.0, i=0, v_r=0.0, v_i=0.0, tau=1, tmp=0.0, min=0.0, tau_min=0, yin=0.0;

    for(i=0; i<INP_SZ; i++) {
      v_r = values[INP_SZ+(i*2)];
      v_i = values[INP_SZ+(i*2)+1];
      sum += (v_r*v_r + v_i*v_i)*weight[i];
    }
    sum *= 2.0;

    if(sum < 0.01) {
      values[_pitch_idx] = 0.0;
      return;
    }
    min = 999999.;
    tau_min = tauMin;
    for(tau=1; tau<tauMax; tau++) {
      yin = sum - values[INP_SZ+(tau*2)];
      tmp += yin;
      yin *= tau/tmp;
      if(tau >= tauMin && yin < min) {
        min = yin;
        tau_min = tau;
      }
    }
    values[_pitch_idx] = Constants.sampleRate / tau_min;
  }

  function process(offs) {
    mod_asm.FFT(offs);
    pitchYin();
    RMS();
  }

  return {
    energy_idx: function(){return _energy_idx;},
    pitch_idx: function(){return _pitch_idx;},
    inp_idx: function(){return 0;},
    process: process,
    heapF64: values
  };
}

var m = null;
window.Module = function() {
  if(m) return m;
  return m = Essentia(window);
};

})(window);
