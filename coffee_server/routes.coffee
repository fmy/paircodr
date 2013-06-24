mongoose = require 'mongoose'
model = require "./model.js"
Code = model.Code

exports.index = (req, res) ->
  res.render 'index', { title: 'paircodr' }

exports.new = (req, res) ->
  code = new Code
  code.save (err) ->
    res.redirect "/#{code._id}"

exports.code = (req, res) ->
  Code.findById req.params.id, (err, code) ->
    console.log !code
    return res.redirect "/" if err or !code
    res.render "code/index",
      title: code.title
      code: code
