fs      = require 'fs'
{print} = require 'util'

{spawn, exec} = require 'child_process'

# APP
app_path     = __dirname
js_path      = "#{app_path}/public/javascripts"
css_path     = "#{app_path}/public/stylesheets"
scss_path    = "#{app_path}/scss"
coffee_path  = "#{app_path}/public/coffeescripts"
app_src_path = "#{app_path}/coffee_server"

# COMPILERS
sass_exec    = 'scss'
coffee_exec  = app_path + '/node_modules/coffee-script/bin/coffee'
ugly_exec    = app_path + '/node_modules/uglify-js/bin/uglifyjs'

task 'minify', 'start uglify compressor', ->
  to_param  = 'xargs cat'
  js_files  = "find #{js_path} -maxdepth 1 -name '*.js'"
  ugly_file = app_path + '/public/javascripts/cumulative/script.js'
  uglify_it = "#{js_files} | #{to_param} | #{ugly_exec} > #{ugly_file}"
  #print "UGLY\n"
  #print "#{uglify_it}\n"
  ugly_proc = exec uglify_it
  ugly_proc.stdout.on 'data', (data) -> print data.toString()
  ugly_proc.stderr.on 'data', (data) -> print data.toString()
  #print "~UGLY\n"

task 'dev', 'Dev Env : Compile CoffeeScript/SCSS source files', ->
  # COFFEE
  # watch app.coffee, routes.coffee
  coffee_watcher_app = spawn coffee_exec, ['-cbw --bare', '-o', app_path, app_src_path]
  coffee_watcher_app.stdout.on 'data', (data) -> print data.toString()
  coffee_watcher_app.stderr.on 'data', (data) -> print data.toString()
  coffee_watcher_app.on 'exit', (status) -> callback?() if status is 0
  # watch clients *.coffee
  coffee_watcher_clients = spawn coffee_exec, ['-cw --bare',  '-o', js_path, coffee_path]
  coffee_watcher_clients.stdout.on 'data', (data) ->
    print data.toString()
    invoke 'minify'
  coffee_watcher_clients.stderr.on 'data', (data) -> print data.toString()
  coffee_watcher_clients.on 'exit', (status) -> callback?() if status is 0

  # SCSS
  sass_watcher = spawn sass_exec, ['--watch', "#{scss_path}:#{css_path}", '-t', 'expanded']
  sass_watcher.stdout.on 'data', (data) -> print data.toString()
  sass_watcher.stderr.on 'data', (data) -> print data.toString()
  sass_watcher.on 'exit', (status) -> callback?() if status is 0