# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class JadePlugin extends BasePlugin
		# Plugin name
		name: 'jade'

		# Plugin configuration
		config:
			jadeOptions:
				pretty: false
			environments:
				development:
					jadeOptions:
						pretty: true

		# Render some content
		render: (opts,next) ->
			# Prepare
			{inExtension,templateData,file} = opts
			config = @config

			# Check our extension
			if inExtension is 'jade'
				# Requires
				jade = require('jade')

				# Prepare
				jadeOptions =
					filename: file.get('fullPath')

				# Extend
				jadeOptions[key] = value  for own key,value of config.jadeOptions  if config.jadeOptions

				# Render
				try
					opts.content = jade.compile(opts.content,jadeOptions)(templateData)
				catch err
					return next(err)

			# Done, return back to DocPad
			return next()
