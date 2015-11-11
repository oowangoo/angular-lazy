path = require("path")

module.exports = (grunt)->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  config = {
    compiled:'.compiled'
  }

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffee:
      demo:
        cwd:"demo"
        src:"**/*.coffee"
        dest:"dest"
        ext:".js"
        expand:true
      lazy:
        cwd:"src"
        src:"**/*.coffee"
        dest:"dest/javascripts"
        ext:".js"
        expand:true
      test:
        cwd:"test"
        src:"**/*.coffee"
        dest:"test/.compiled"
        ext:".js"
        expand:true
    copy:
      html:
        files:[{
          cwd:"demo"
          src:"**/*.html"
          dest:"dest"
          ext:".html"
          expand:true
        }]
    clean:[
      'test/.compiled'
      'dest'
    ]
    ngmin:{
      lazy:
        expand: true,
        cwd:"dest/javascripts"
        src:"*.js"
        dest:"dest/javascripts"
    }
    uglify:{
      options:
        sourceMap: true
        sourceMapIncludeSources:true
      lazy:
        files:
          "dest/javascripts/lazy.min.js":["dest/javascripts/lazy.js"]
    }
    compass:
      files:
        options:
          sassDir:'stylesheets'
          cssDir:'dest/stylesheets'
          require: 'animate'
    nodemon:
      dev:
        script: 'app.js',
        options:
          cwd: __dirname,
          watch:['app.js','dest']
          env:             
            DEV: true,
            PORT: 3000,
            NODE_ENV: 'development',
            DEBUG: '*,-send,-connect:dispatcher,-express:router'
    watch:
      options:
        livereload: true
      lazy:
        files:['src/**/*.coffee']
        tasks:['coffee:lazy']
      demo:
        files:["demo/**/*.coffee"]
        tasks:['coffee:demo']
      template:
        files:["demo/**/*.html"]
        tasks:['copy:html']
      test:
        files:['test/**/*.coffee']
        tasks:['coffee:test']
      compass: 
        files: ['dest/stylesheets/**/*.{scss,sass}']
        tasks: ['compass']
      views:
        files:['views/**/*.html']
    concurrent: 
      options: 
        logConcurrentOutput: true
      dev: ['nodemon', 'watch']
    
  grunt.registerTask("r",['clean','coffee:lazy','ngmin','uglify'])
  grunt.registerTask('build',['clean','coffee','compass','copy:html'])
  grunt.registerTask('s',['build','concurrent:dev'])

  grunt.registerTask "default", ["build"]
  return 