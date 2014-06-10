require 'ox'

module Siresta
  module XML
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
