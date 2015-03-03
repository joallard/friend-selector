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
    clean: ["build/*"]

  grunt.loadNpmTasks 'grunt-bower'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-sass'

  grunt.registerTask 'compile', ['coffee', 'sass']
  grunt.registerTask 'default', ['clean', 'compile']
