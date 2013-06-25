# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class JadePlugin extends BasePlugin
		# Name
		name: 'jade'

		# Configuration
		config:
			jadeOptions:
				pretty: false
			environments:
				development:
					jadeOptions:
						pretty: true

		# Constructor
		constructor: ->
			# Prepare
			super

			# Require Jade
			@jade = require('jade')

			# Chain
			@

		# Generate Before
		generateBefore: ->
			# Prepare
			templateData = @docpad.getTemplateData()
			filters = @jade.filters
			addTemplateDataAsFilter = (key,value) ->
				filters[key] ?= (str,opts) ->
					# No special opts
					if opts.args
						args = str.split(/\s*\n\s*/)
						return value.apply(templateData, args)
					else
						args = [str,opts]
						return value.apply(templateData ,args)

			# Add template helpers as jade filters
			for own key,value of templateData
				if Object::toString.call(value) is '[object Function]'
					addTemplateDataAsFilter(key, value)

			# Chain
			@

		# Render some content
		render: (opts,next) ->
			# Prepare
			{inExtension,templateData,file} = opts
			config = @config

			# Check our extension
			if inExtension is 'jade'
				# Prepare
				jadeOptions =
					filename: file.get('fullPath')

				# Extend
				jadeOptions[key] = value  for own key,value of config.jadeOptions  if config.jadeOptions

				# Render
				try
					# Ensure template data is bounded
					# required for jade 0.31+, earlier versions didn't require it
					for own key,value of templateData
						if Object::toString.call(value) is '[object Function]'
							templateData[key] = value.bind(templateData)

					# Compile
					opts.content = @jade.compile(opts.content, jadeOptions)(templateData)
				catch err
					return next(err)

			# Done, return back to DocPad
			return next()
