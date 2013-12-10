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

			# Add the template helper as a jade filter
			addTemplateHelperAsJadeFilter = (key, value) ->
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

			# Add template helpers as jade filters
			for own key,value of templateData
				if Object::toString.call(value) is '[object Function]'
					addTemplateHelperAsJadeFilter(key, value)

			# Chain
			@

		# Render some content
		render: (opts, next) ->
			# Prepare
			{inExtension, templateData, file} = opts
			config = @config

			# Check our extension
			if inExtension is 'jade'
				# Prepare
				jadeOptions =
					filename: file.get('fullPath')

				# Extend
				((jadeOptions[key] = value) for own key,value of config.jadeOptions) if config.jadeOptions

				# Ensure template helpers are bound correctly
				# Needed for Jade v0.31+
				for own key, value of opts.templateData
					if value?.bind is Function::bind  # we do this style of check, as underscore is a function that has it's own bind
						opts.templateData[key] = value.bind(opts.templateData)

				try
					# Compile
					opts.content = @jade.compile(opts.content, jadeOptions)(templateData)
				catch err
					return next(err)

			# Done, return back to DocPad
			return next()
