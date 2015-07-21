module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      elm: {
        files: ['src/elm/**'],
        tasks: ['elm', 'concat:dev', 'appcache:dev']
      },
      stylesheets: {
        files: ['config.rb', 'src/stylesheets/**'],
        tasks: ['compass:dev', 'appcache:dev']
      },
      javascripts: {
        files: ['src/javascripts/**'],
        tasks: ['concat:dev', 'appcache:dev']
      },
      html: {
        files: ['src/index.html'],
        tasks: ['htmlmin', 'appcache:dev']
      },
      images: {
        files: ['src/images/**'],
        tasks: ['copy:images', 'appcache:dev']
      },
      fonts: {
        files: ['src/fonts/**'],
        tasks: ['copy:fonts', 'appcache:dev']
      },
    },

    connect: {
      dev: {
        options: {
          port: 8000,
          base: 'dist',
        }
      }
    },

    concat: {
      dev: {
        sourceMap: true,
        src: ['build/elm.js', 'src/javascripts/**/*.js'],
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

    uglify: {
      prod: {
        options: {
          sourceMap: false
        },
        files: {
          'dist/main.js': 'build/main.js'
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
      dev: {
        dest: 'dist/<%= pkg.name %>.appcache',
        cache: {
          patterns: ['dist/**/*'],
          literals: [
            'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/',
            'https://code.jquery.com/jquery-2.1.4.min.js',
          ],
        },
        fallback: [
          '/ /cache/index.html',
        ]
      },
      prod: '<%= appcache.dev %>'
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
    'clean', 'elm', 'concat:dev', 'compass:dev', 'htmlmin:dev', 'copy:images',
    'copy:fonts', 'appcache:dev']);
  grunt.registerTask('build:prod', [
    'clean', 'elm', 'concat:prod', 'uglify:prod', 'compass:prod',
    'htmlmin:prod', 'copy:images', 'copy:fonts', 'appcache:prod']);
  grunt.registerTask('build', ['build:dev']);
  grunt.registerTask('run', ['connect:dev', 'watch']);
  grunt.registerTask('default', ['build', 'run']);
};
