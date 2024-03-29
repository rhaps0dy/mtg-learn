module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      options: {
        // livereload interferes with the xml files served from grunt
        livereload: false
      },
      elm: {
        files: ['src/elm/**'],
        tasks: ['elm', 'concat:dev']
      },
      stylesheets: {
        files: ['config.rb', 'src/stylesheets/**'],
        tasks: ['compass:dev']
      },
      javascripts: {
        files: ['src/javascripts/**'],
        tasks: ['concat:dev', 'uglify:dev']
      },
      html: {
        files: ['src/index.html'],
        tasks: ['htmlmin']
      },
      images: {
        files: ['src/images/**'],
        tasks: ['copy:images']
      },
      fonts: {
        files: ['src/fonts/**'],
        tasks: ['copy:fonts']
      },
      data: {
        files: ['src/data/**'],
        tasks: ['copy:data']
      },
      emscripten: {
        files: ['src/cpp/*.js'],
        tasks: ['copy:emscripten']
      },
    },

    connect: {
      dev: {
        options: {
          port: 8000,
          base: 'dist',
          livereload: false
        }
      }
    },

    concat: {
      dev: {
        sourceMap: true,
        // TODO: Order of the concatenation of the JS is now important. Make it
        // so it is not. Browserify is probably a good lib for that
        src: ['build/elm.js', 'src/javascripts/essentia.js', 'src/javascripts/ports.js'],
        dest: 'dist/main.js' // we skip uglifying in development
      },
      prod: {
        src: '<%= concat.dev.src %>',
        dest: 'build/main.js'
      }
    },

    copy: {
      images: {
        expand: true,
        cwd: 'src',
        src: 'images/**',
        dest: 'dist/'
      },
      fonts: {
        expand: true,
        cwd: 'src',
        src: 'fonts/**',
        dest: 'dist/'
      },
      data: {
        expand: true,
        cwd: 'src',
        src: 'data/**',
        dest: 'dist/'
      },
      emscripten: {
        expand: true,
        cwd: 'src/cpp',
        src: ['*.js', '*.js.mem'],
        dest: 'dist/'
      },
    },

    elm: {
      compile: {
        files: {
          'build/elm.js': 'src/elm/Main.elm'
        }
      }
    },

    compass: {
      dev: {
        options: {
          outputStyle: 'expanded',
          environment: 'development'
        }
      },
      prod: {
        options: {
          outputStyle: 'compressed',
          environment: 'production'
        }
      }
    },

    // we uglify only the metronome worker in dev
    uglify: {
      dev: {
        options: {
          sourceMap: true
        },
        files: {
          'dist/metronome_worker.js': 'src/javascripts/metronome_worker.js'
        }
      },
      prod: {
        options: {
          sourceMap: false
        },
        files: {
          'dist/main.js': 'build/main.js',
          'dist/metronome_worker.js': 'src/javascripts/metronome_worker.js'
        }
      }
    },

    htmlmin: {
      options: {
        removeComments: true,
        collapseWhitespace: true
      },
      dev: {
        files: {
          'dist/index.html': 'src/index.html'
        }
      },
      prod: '<%= htmlmin.dev %>'
    },

    appcache: {
      options: {
        basePath: 'dist'
      },
      prod: {
        dest: 'dist/<%= pkg.name %>.appcache',
        cache: {
          patterns: ['dist/*', 'dist/images/*', 'dist/fonts/*'],
          literals: [
            '//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css',
            '//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff',
	    '//cwilso.github.io/AudioContext-MonkeyPatch/AudioContextMonkeyPatch.js'
          ],
        },
        network: [
          'data/blueBossa.ogg',
          'data/blueBossa.xml',
          '//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css',
          '//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff',
        ],
        fallback: [
          '/ index.html'
        ],
      }
    },
    clean: ['dist', 'build']
  });

  [ 'grunt-appcache'
  , 'grunt-contrib-clean'
  , 'grunt-contrib-compass'
  , 'grunt-contrib-concat'
  , 'grunt-contrib-connect'
  , 'grunt-contrib-copy'
  , 'grunt-contrib-htmlmin'
  , 'grunt-contrib-jshint'
  , 'grunt-contrib-nodeunit'
  , 'grunt-contrib-uglify'
  , 'grunt-contrib-watch'
  , 'grunt-elm'
  ].forEach(grunt.loadNpmTasks);

  grunt.registerTask('build:dev', [
    'clean', 'elm', 'concat:dev', 'uglify:dev', 'compass:dev', 'htmlmin:dev',
    'copy']);
  grunt.registerTask('build:prod', [
    'clean', 'elm', 'concat:prod', 'uglify:prod', 'compass:prod',
    'htmlmin:prod', 'copy', 'appcache:prod']);
  grunt.registerTask('build', ['build:dev']);
  grunt.registerTask('prod', ['build:prod']);
  grunt.registerTask('run', ['connect:dev', 'watch']);
  grunt.registerTask('default', ['build', 'run']);
};
