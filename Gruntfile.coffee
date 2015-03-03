module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        files:
          'build/friend-selector.js': 'src/friend-selector.js.coffee'
    clean: ["build/*"]

  grunt.loadNpmTasks 'grunt-bower'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', ['clean', 'coffee']
