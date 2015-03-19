path = require("path")

module.exports = (grunt)->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  config = {
    compiled:'.compiled'
  }

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffee:
      files:
        cwd:"src"
        src:"**/*.coffee"
        dest:"dist/javascripts"
        ext:".js"
        expand:true
      test:
        cwd:"test"
        src:"**/*.coffee"
        dest:"test/.compiled"
        ext:".js"
        expand:true
    copy:
      build:
        files:[{
          cwd:"src"
          src:"**/*.js"
          expand:true
          dest:"dist/javascripts"
        }]
    clean:[
      'test/.compiled'
      'dist'
    ]
    compass:
      files:
        options:
          sassDir:'stylesheets'
          cssDir:'dist/stylesheets'
          require: 'animate'
    nodemon:
      dev:
        script: 'app.js',
        options:
          cwd: __dirname,
          watch:['dist']
          env:             
            DEV: true,
            PORT: 3000,
            NODE_ENV: 'development',
            DEBUG: '*,-send,-connect:dispatcher,-express:router'
         

#    bump:
#      options:
#        files:['package.json','bower.json']
#        commitFiles:['-a']
#        pushTo:'gitlab'
#    karma:
#      unit:
#        configFile:"karma.conf.js"
#      backgrund:
#        configFile:"karma.conf.js"
#        options:
#          singleRun:true
    watch:
      options:
        livereload: true
      src:
        files:["src/**/*.coffee"]
        tasks:['coffee:files']
      test:
        files:['test/**/*.coffee']
        tasks:['coffee:test']
      compass: 
        files: ['dist/stylesheets/**/*.{scss,sass}']
        tasks: ['compass']

    
    concurrent: 
      options: 
        logConcurrentOutput: true
      dev: ['nodemon', 'watch']
    
  
      

  grunt.registerTask('build',['clean','coffee','compass','copy:build'])
  grunt.registerTask('s',['build','concurrent:dev'])

  grunt.registerTask "default", ["build"]
  return 