module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        files:
          'build/friend-selector.js': 'src/friend-selector.js.coffee'
    sass:
      compile:
        files:
          'build/friend-selector.css': 'src/friend-selector.css.sass'
    concat:
      compile:
        files:
          'build/friend-selector.all.js': [
            'node_modules/fb-login/build/fb-login.js',
            'build/friend-selector.js'
          ]
    uglify:
      compile:
        files: [
          'build/friend-selector.min.js': 'build/friend-selector.js',
          'build/friend-selector.all.min.js': 'build/friend-selector.all.js',
        ]

    clean: ["build/*"]

  grunt.loadNpmTasks 'grunt-bower'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'compile', ['coffee', 'sass', 'concat', 'uglify']
  grunt.registerTask 'default', ['clean', 'compile']
