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
    clean:
      build:['.compiled']
      release:['dest']
    concat:
      dest:
        src:["src/*.coffee"]
        dest:".compiled/angular-lazy.coffee"
    copy:
      dest:
        expand:true
        cwd:".compiled"
        src:['src/*.*','angular-lazy.*','!angular-lazy.coffee']
        dest:"dest"
    uglify:
      options:
        banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %> */'
        sourceMap: true
        sourceMapIncludeSources:true
      lazy:
        files:[{
          expand: true,
          cwd:".compiled/src"
          ext:".min.js"
          src:"**/*.js"
          dest:".compiled/src"
        }]
      dest:
        files:{
          '.compiled/angular-lazy.min.js':".compiled/angular-lazy.js"
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
    bump:
      options:
        files:[]
        commit: true,
        commitMessage: 'Release <%= pkg.version%>',
        commitFiles: ['dest/','package.json','bower.json'],
        createTag: true,
        tagName: '<%= pkg.version%>',
        tagMessage: 'Version <%= pkg.version%>'
        push:true
        pushTo:'origin'

  grunt.registerTask "build",[
    'clean:build'
    "coffee:lazy"
    "coffee:test"
  ]
  grunt.registerTask "default", ["build"]

  grunt.registerTask("test",['build','concurrent:test'])

  grunt.registerTask("buildRelease",[
    'clean:build'
    'concat:dest'
    "coffee:lazy" # only to copy dest
    "coffee:dest"
    "coffee:test"
    "uglify:lazy"
    "uglify:dest"
    "rsm"
  ])
  grunt.registerTask("prepare-release",()->
    bower = grunt.file.readJSON('bower.json')
    version = bower.version
    if(version isnt grunt.config('pkg.version'))
      throw 'Version mismatch in bower.json';
  )
  grunt.registerTask('release',['buildRelease','karma:release',"clean:release",'copy:dest','prepare-release','bump'])

  grunt.registerTask('rsm','拷贝.map 文件，并读取js生成.js->.map对照表,同时删除min.js的source map引用',()->
    SOURMAP_REG = /\/\/# sourceMappingURL=(\S+)/;
    JS_REG = /\.min\.js$/;
    MAP_REG = /\.map$/;
    initRegExp = ()->
      SOURMAP_REG.lastIndex = 0;
      JS_REG.lastIndex = 0;
      MAP_REG.lastIndex = 0;
    postMappingJSON = (files)->
      mapping = {};
      postDir = (dir)->   
        grunt.file.recurse(dir,(abspath, rootdir, subdir, filename)->
          postFile(abspath)
        );
      postFile = (filepath)->
        initRegExp()

        if (JS_REG.test(filepath))
          content = grunt.file.read(filepath);
          RegExp.$1 = '';
          if (!SOURMAP_REG.test(content)) 
            return;
          #移除最底下sourcemap 注释
          content = content.replace(SOURMAP_REG, '');
          grunt.file.write(filepath,content,{encoding:'utf-8'});

      if grunt.file.isDir(files)
        postDir(files)
      else if grunt.file.isFile(files)
        postFile(files)
      return ;

    src = postMappingJSON('.compiled/src')
    lazy = postMappingJSON('.compiled/angular-lazy.min.js')
  );
 
  return 