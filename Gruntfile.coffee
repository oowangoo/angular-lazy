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
      dest:
        src:".compiled/angular-lazy.coffee"
        dest:"."
        ext:".js"
        expand:true
    clean:[
      '.compiled'
      'dest'
    ]
    concat:
      dest:
        src:["src/*.coffee"]
        dest:".compiled/angular-lazy.coffee"
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
      release:
        configFile:"karma-release.conf.js"
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
      test: ['watch','karma:unit']
    

  grunt.registerTask "build",[
    'clean'
    "coffee:lazy"
    "coffee:test"
  ]
  grunt.registerTask "default", ["build"]

  grunt.registerTask("test",['build','concurrent:test'])

  grunt.registerTask("buildRelease",[
    'clean'
    'concat:dest'
    "coffee:dest"
    "coffee:test"
  ])
  grunt.registerTask('release',['buildRelease','karma:release'])

  return 