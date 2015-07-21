module PitchSource where

import Array exposing (Array)
import Array
import Time exposing (Time)
import Time
import Signal exposing (Signal, (<~), (~))

soundWindowNSamples : Int
soundWindowNSamples = 1024

-- This gives 43 FPS
fps : Float
fps = (44100 / toFloat soundWindowNSamples)

hardcodedFreqs : Array Float
hardcodedFreqs = Array.fromList [313.533, 301.943, 2730.69, 228.917, 230.463, 232.534, 233.59, 233.613, 233.362, 232.986, 232.809, 232.643, 232.938, 233.601, 234.439, 235.66, 236.282, 234.98, 262.858, 263.583, 264.058, 264.011, 263.727, 263.56, 263.795, 263.765, 263.928, 264.094, 264.375, 264.87, 265.494, 266.176, 275.543, 277.578, 279.025, 278.484, 277.159, 276.923, 277.233, 277.447, 277.753, 277.661, 277.55, 278.236, 279.639, 280.123, 280.869, 310.936, 313.761, 314.423, 313.525, 312.983, 312.508, 312.485, 312.672, 312.574, 312.466, 312.677, 313.213, 314.344, 315.378, 321.768, 349.685, 352.615, 354.666, 354.595, 354.088, 354.119, 354.15, 354.176, 354.442, 354.349, 363.875, 371.132, 372.452, 371.953, 371.789, 371.99, 372.541, 373.457, 411.395, 417.592, 416.07, 416.453, 416.967, 416.476, 416.847, 417.929, 418.854, 418.981, 421.272, 418.036, 404.771, 405.856, 411.437, 414.245, 416.05, 433.337, 435.83, 435.774, 435.484, 435.659, 437.344, 439.193, 439.39, 439.558, 439.738, 440.056, 440.517, 441.196, 441.614, 442.435, 442.222, 442.03, 441.198, 440.54, 440.413, 440.221, 440.337, 440.193, 439.961, 439.779, 439.908, 440.602, 440.707, 440.948, 441.017, 440.953, 441.334, 441.683, 441.794, 442.451, 442.213, 442.007, 442.538, 443.667, 443.656, 443.791, 443.116, 442.226, 441.751, 441.478, 441.713, 442.017, 442.603, 443.679, 444.538, 444.525, 443.532, 441.447, 439.421, 438.783, 440.344, 442.229, 443.66, 444.532, 444.739, 443.988, 442.401, 440.793, 440.238, 441.179, 443.019, 444.884, 445.504, 445.391, 444.351, 442.542, 441.023, 441.044, 442.277, 444.301, 446.026, 446.744, 445.861, 444.286, 441.904, 440.308, 440.991, 442.493, 444.379, 446.35, 446.364, 444.936, 442.71, 441.245, 442.057, 443.616, 445.232, 446.371, 447.02, 446.432, 445.06, 442.7, 441.821, 442.601, 443.603, 444.682, 445.198, 444.947, 443.756, 442.493, 442.211, 442.72, 443.351, 443.462, 443.051, 442.467, 442.225, 442.658, 443.797, 444.927, 445.377, 443.562, 442.099, 463.756, 466.647, 466.999, 466.12, 465.19, 465.001, 465.218, 465.183, 465.408, 465.629, 466.334, 467.368, 467.862, 468.66, 469.224, 469.884, 470.548, 471.577, 469.302, 460.844, 448.232, 380.079, 373.906, 375.945, 383.103, 388.469, 392.003, 393.396, 393.36, 392.771, 391.813, 390.856, 390.796, 390.995, 391.45, 391.276, 390.738, 390.075, 389.954, 390.261, 390.652, 390.622, 390.517, 390.434, 390.23, 390.553, 390.779, 390.431, 390.281, 390.423, 390.883, 390.968, 391.097, 390.883, 391.441, 392.643, 393.262, 393.278, 464.942, 464.944, 465.379, 464.529, 460.411, 464.28, 462.679, 462.205, 463.291, 463.978, 464.642, 389.811, 391.099, 390.384, 386.792, 382.279, 154.534, 312.308, 312.166, 311.889, 311.387, 310.943, 311.954, 244.875, 245.83, 245.915, 245.588, 245.101, 245.292, 245.787, 246.43, 245.773, 233.96, 233.602, 233.247, 232.942, 232.254, 231.559, 231.523, 231.264, 231.555, 231.965, 232.153, 232.165, 232.318, 232.264, 232.148, 231.896, 231.888, 231.874, 231.81, 231.327, 230.698, 230.813, 231.415, 232.629, 234.304, 235.035, 234.978, 233.805, 232.186, 231.703, 234.382, 237.703, 239.171, 236.963, 234.311, 232.981, 233.058, 232.904, 233.241, 232.922, 232.624, 233.403, 233.457, 232.814, 232.507, 232.674, 232.707, 232.634, 232.946, 233.36, 233.141, 233.814, 232.315, 232.572, 232.219, 233.698, 232.465, 231.08, 233.139, 232.807, 233.343, 235.561, 398.808, 401.001, 377.759, 394.397, 399.661, 405.007, 408.286, 408.686, 409.272, 410.084, 410.375, 410.836, 411.163, 411.537, 411.798, 409.793, 396.782, 396.383, 393.174, 398.827, 405.669, 418.891, 434.006, 438.16, 440.103, 440.831, 440.728, 440.948, 441.37, 441.432, 441.191, 441.335, 441.638, 441.952, 441.822, 441.648, 441.165, 440.81, 440.553, 440.428, 440.287, 440.305, 439.694, 439.289, 439.411, 439.279, 439.18, 439.354, 439.626, 439.545, 439.356, 439.404, 439.686, 439.99, 440.171, 440.054, 439.869, 439.928, 440.032, 440.162, 440.204, 440.2, 440.482, 441.746, 444.024, 443.906, 442.289, 441.287, 441.177, 466.112, 467.25, 466.616, 464.974, 462.515, 461.415, 461.522, 462.242, 463.417, 463.24, 463.183, 463.461, 463.779, 464.814, 467.473, 469.013, 469.061, 464.221, 397.058, 395.128, 394.585, 393.946, 393.059, 391.985, 391.346, 391.585, 391.45, 391.532, 391.779, 391.909, 392.087, 392.124, 392.401, 392.488, 392.894, 393.286, 393.356, 393.266, 393.362, 393.837, 394.272, 395.241, 395.557, 393.771, 395.567, 388.304, 385.421, 388.2, 394.734, 400.13, 404.215, 408.368, 409.919, 410.48, 410.262, 410.777, 411.212, 411.527, 411.855, 411.791, 411.364, 410.885, 411.263, 411.129, 411.151, 411.392, 411.273, 407.577, 391.922, 389.894, 388.266, 371.44, 364.316, 361.877, 348.943, 344.72, 311.585, 310.642, 310.186, 298.55, 295.883, 295.725, 295.547, 295.19, 295.028, 294.503, 293.864, 293.418, 293.295, 293.189, 293.356, 293.261, 293.091, 293.333, 293.417, 293.363, 293.283, 293.228, 293.234, 293.009, 293.169, 293.262, 293.369, 293.31, 293.549, 293.913, 294.38, 294.46, 294.554, 294.563, 294.609, 294.766, 294.895, 295.19, 295.295, 295.281, 295.303, 295.491, 295.52, 295.478, 295.48, 295.64, 295.922, 296.268, 296.469, 297.079, 297.167, 299.041, 311.259, 312.57, 313.578, 314.073, 314.12, 311.46, 300.101, 327.847, 330.041, 329.469, 329.899, 329.754, 329.464, 330.888, 338.556, 348.433, 349.588, 349.669, 349.348, 348.846, 348.695, 347.738, 340.265, 310.082, 310.801, 311.148, 310.997, 310.303, 309.358, 309.163, 308.344, 287.915, 278.759, 278.221, 278.575, 279.41, 283.808, 298.322, 302.362, 295.137, 296.49, 296.717, 296.176, 295.249, 294.943, 295.846, 297.182, 298.521, 297.331, 279.992, 277.942, 277.958, 278.025, 277.468, 276.927, 277.125, 277.97, 278.874, 278.309, 273.064, 265.954, 265.014, 264.598, 264.743, 264.005, 263.921, 264.772, 264.842, 265.671, 269.85, 265.932, 262.148, 245.404, 246.06, 245.859, 245.928, 245.995, 246.25, 246.563, 246.591, 247.409, 247.85, 247.858, 235.577, 234.596, 234.813, 234.519, 234.223, 233.493, 233.15, 233.455, 233.455, 233.177, 232.896, 232.81, 232.927, 233.236, 233.553, 233.529, 233.496, 233.921, 234.221, 234.16, 233.353, 232.303, 232.855, 236.499, 238.696, 240.721, 236.301, 233.77, 234.489, 234.435, 233.529, 232.562, 234.808, 232.831, 235.344, 233.694, 235.728, 234.871, 232.028, 231.658, 234.576, 231.75, 234.193, 229.721, 230.51, 517.344, 228.87, 237.765, 231.63, 515.175, 347.33, 172.052, 236.588, 234.419, 3135.83, 230.937, 283.387, 319.011, 321.051, 324.985, 327.479, 333.667, 349.419, 350.62, 350.779, 350.814, 350.386, 350.371, 350.25, 349.983, 349.731, 349.192, 349.236, 349, 348.912, 349.923, 275.552, 276.474, 276.773, 276.549, 276.167, 275.739, 275.642, 275.661, 275.826, 275.973, 276.028, 276.862, 277.497, 278.196, 277.851, 276.628, 275.627, 276.613, 277.424, 276.912, 276.529, 276.207, 276.244, 275.955, 275.559, 275.188, 275.325, 275.483, 275.606, 275.393, 275.637, 275.958, 276.504, 277.003, 277.526, 278.297, 278.657, 278.652, 278.152, 277.449, 276.698, 276.039, 276.454, 277.267, 278.03, 278.924, 278.973, 279.022, 278.786, 277.938, 276.782, 275.621, 274.719, 275.482, 276.869, 278.144, 278.982, 279.225, 278.793, 278.276, 276.937, 275.683, 275.313, 276.287, 277.495, 278.229, 278.797, 278.569, 277.575, 276.721, 275.868, 275.759, 276.622, 277.142, 277.704, 277.975, 278.101, 278.098, 275.195, 235.902, 235.576, 235.31, 234.316, 232.666, 231.673, 231.828, 231.901, 232.383, 233.027, 233.479, 234.777, 244.611, 247.919, 248.06, 244.741, 235.63, 235.621, 235.33, 236.312, 208.944, 208.124, 208.13, 208.06, 208.01, 208.25, 207.992, 207.786, 207.547, 207.501, 207.997, 208.468, 209.254, 209.827, 209.438, 208.183, 204.171, 161.408, 328.808, 334.537, 349.214, 348.995, 349.412, 350.349, 351.67, 352.148, 352.245, 360.839, 366.995, 385.838, 386.113, 384.833, 386.375, 399.319, 410.683, 414.429, 414.831, 414.086, 413.026, 411.842, 411.84, 412.27, 412.437, 412.141, 411.765, 411.71, 411.861, 412.289, 412.353, 412.928, 412.986, 413.066, 412.967, 412.752, 412.029, 412.104, 412.328, 413.741, 415.261, 416.404, 417.014, 416.786, 415.508, 413.127, 411.417, 411.794, 413.325, 415.722, 417.913, 418.207, 417.726, 416.173, 414.376, 412.19, 412.144, 413.604, 416.105, 418.387, 419.144, 418.68, 418.155, 416.906, 415.546, 415.022, 415.56, 417.035, 418.526, 419.458, 419.77, 418.769, 416.893, 414.013, 412.659, 413.685, 415.765, 420.481, 422.835, 422.877, 420.237, 417.466, 415.126, 414.086, 415.647, 418.685, 421.177, 423.06, 422.979, 420.284, 415.63, 413.086, 415.126, 422.025, 426.957, 426.477, 419.619, 418.245, 416.689, 418.269, 417.931, 419.794, 421.29, 420.625, 420.148, 416.699, 417.501, 421.099, 417.954, 207.475, 430.249, 514.543, 419.178]


signal : Signal Float
signal =
    let frameSignal = Time.fps fps
        indexSignal = Signal.foldp (\_ b -> (b + 1) % Array.length hardcodedFreqs) 0 frameSignal
    in (\i -> case Array.get i hardcodedFreqs of
                Just a -> a
                Nothing -> 0) <~ indexSignal
