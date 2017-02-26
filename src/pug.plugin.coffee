# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class PugPlugin extends BasePlugin
		# Name
		name: 'pug'

		# Configuration
		config:
			pugOptions:
				pretty: false
			environments:
				development:
					pugOptions:
						pretty: true

		# Constructor
		constructor: ->
			# Prepare
			super

			# Require Pug
			@pug = require('pug')

			# Chain
			@

		# Generate Before
		generateBefore: ->
			# Prepare
			templateData = @docpad.getTemplateData()
			filters = @pug.filters

			# Add the template helper as a pug filter
			addTemplateHelperAsPugFilter = (key, value) ->
				filters[key] ?= (str, opts) ->
					# No special opts
					if opts.args
						args = str.split(/\s*\n\s*/)
						result = value.apply(templateData, args)
					# With special opts
					else
						args = [str,opts]
						result = value.apply(templateData, args)

					# Return the result of our template helper
					return result

			# Add template helpers as pug filters
			for own key,value of templateData
				if Object::toString.call(value) is '[object Function]'
					addTemplateHelperAsPugFilter(key, value)

			# Chain
			@

		# Render some content
		render: (opts, next) ->
			# Prepare
			{inExtension, templateData, file} = opts
			config = @config

			# Check our extension
			if inExtension is 'pug'
				# Prepare
				pugOptions =
					filename: file.get('fullPath')

				# Extend
				((pugOptions[key] = value) for own key,value of config.pugOptions) if config.pugOptions

				# Ensure template helpers are bound correctly
				# Needed for Pug v0.31+
				for own key, value of opts.templateData
					if value?.bind is Function::bind  # we do this style of check, as underscore is a function that has it's own bind
						opts.templateData[key] = value.bind(opts.templateData)

				try
					# Compile
					opts.content = @pug.compile(opts.content, pugOptions)(templateData)
				catch err
					return next(err)

			# Done, return back to DocPad
			return next()
