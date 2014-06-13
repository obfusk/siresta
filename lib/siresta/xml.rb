# --                                                            ; {{{1
#
# File        : siresta/xml.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'ox'

module Siresta
  module XML
    # parse XML
    #
    # ```
    # Siresta::XML.parse '<foo><bar id="99">hi!</bar></foo>'
    # # =>  { tag: 'foo', attrs: {}, contents: [
    #         { tag: 'bar', attrs: { id: 99 }, contents: ['hi!'] }
    #       ] }
    # ```
    def self.parse(xml)
      ox_elem = Ox.parse xml
      _parse Ox::Document === ox_elem ? ox_elem.root : ox_elem
    end

    def self._parse(ox_elem)
      if String === ox_elem
        ox_elem
      else
        contents = ox_elem.nodes.map { |n| _parse n }
        { tag: ox_elem.name, attrs: ox_elem.attributes, contents: contents }
      end
    end

    # emit XML
    #
    # ```
    # puts Siresta::XML.emit(
    #   { tag: 'foo', attrs: {}, contents: [
    #     { tag: 'bar', attrs: { id: 99 }, contents: ['hi!'] }
    #   ] }
    # )
    # # <?xml version="1.0"?>
    # # <foo>
    # #   <bar id="99">hi!</bar>
    # # </foo>
    # ```
    def self.emit(elem, opts = {})
      ox_doc = Ox::Document.new version: '1.0'
      _emit ox_doc, elem
      Ox.dump ox_doc, { with_xml: true }.merge(opts)
    end

    def self._emit(ox_doc, elem)
      if String === elem
        ox_doc << elem
      else
        ox_elem = Ox::Element.new elem[:tag]
        elem[:attrs].each_pair { |k,v| ox_elem[k] = v }
        ox_doc << ox_elem
        elem[:contents].each { |e| _emit ox_elem, e }
      end
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
