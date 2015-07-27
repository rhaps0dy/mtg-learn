module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      options: {
        livereload: true
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
        tasks: ['concat:dev']
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
    },

    connect: {
      dev: {
        options: {
          port: 8000,
          base: 'dist',
          livereload: true
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
      data: {
        expand: true,
        cwd: 'src',
        src: 'data/**',
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
      prod: {
        dest: 'dist/<%= pkg.name %>.appcache',
        cache: {
          patterns: ['dist/*', 'dist/images/*', 'dist/fonts/*'],
          literals: [
            '//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css',
            '//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff',
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
    'clean', 'elm', 'concat:dev', 'compass:dev', 'htmlmin:dev', 'copy']);
  grunt.registerTask('build:prod', [
    'clean', 'elm', 'concat:prod', 'uglify:prod', 'compass:prod',
    'htmlmin:prod', 'copy', 'appcache:prod']);
  grunt.registerTask('build', ['build:dev']);
  grunt.registerTask('prod', ['build:prod']);
  grunt.registerTask('run', ['connect:dev', 'watch']);
  grunt.registerTask('default', ['build', 'run']);
};
