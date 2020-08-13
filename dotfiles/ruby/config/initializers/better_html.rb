# frozen_string_literal: true

# Configuration for erb-lint/prettier and Rubocop autocorrect
impl = BetterHtml::BetterErb.content_types['html.erb']
BetterHtml::BetterErb.content_types['.erb'] = impl
BetterHtml::BetterErb.content_types['htm.erb'] = impl
