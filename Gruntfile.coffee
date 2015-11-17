path = require("path")

module.exports = (grunt)->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  config = {
    compiled:'.compiled'
  }

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffee:
      lazy:
        cwd:"src"
        bare:true
        src:"**/*.coffee"
        dest:".compiled/src"
        ext:".js"
        expand:true
      test:
        cwd:"test"
        src:"**/*.coffee"
        dest:".compiled/test"
        ext:".js"
        expand:true
    clean:[
      '.compiled'
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

    }
    karma:
      unit:
        configFile:"karma.conf.js"
    nodemon:
      dev:
        script: 'app.js',
        options:
          cwd: __dirname,
          env:             
            DEV: true,
            PORT: 3000,
            NODE_ENV: 'development',
            DEBUG: '*,-send,-connect:dispatcher,-express:router'
    watch:
      options:
        livereload: true
      lazy:
        files:["src/**/*.coffee"]
        tasks:["coffee:lazy"]
      test:
        files:['test/unit/*.coffee']
        tasks:['coffee:test']
    concurrent: 
      options: 
        logConcurrentOutput: true
      dev: ['nodemon', 'watch']
      test: ['watch','nodemon','karma:unit']
    

  grunt.registerTask "build",[
    'clean'
    "coffee:lazy"
    "coffee:test"
  ]
  grunt.registerTask "default", ["build"]

  grunt.registerTask("test",['build','concurrent:test'])
  return 