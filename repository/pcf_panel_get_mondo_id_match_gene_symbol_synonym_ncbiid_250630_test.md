# [PCF] Get MONDO ID by GENE SYMBOL or GENE SYMBOL SYNONYM or NCBI GENE ID - https://pubcasefinder.dbcls.jp/sparql
pcf_panel_get_mondo_id_match_gene_symbol_synonym_ncbiid
## Parameters
* `input_text` Text
  * default: dhodh 
  * example: SF3B4 CERS3 DHOdehase AFD1 170691

## Endpoint
https://pubcasefinder.dbcls.jp/sparql

## `text_list`
```javascript
({input_text}) => {
  //input_text = input_text.replace(/^\s/g,"").replace(/\s$/g,"").replace(/[\s,]/g," ")
  input_text = input_text.replace(/^\s/g,"").replace(/\s$/g,"").replace(/,/g,"")
  return input_text;
  //if (input_text.match(/[^\s]/)) return input_text.split(/\s+/);
  //if (input_text.match(/[^\s]/)) return input_text;
  //return false;
  
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX pf: <http://jena.hpl.hp.com/ARQ/property#>
PREFIX text: <http://jena.apache.org/text#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX bif: <bif:>

#SELECT DISTINCT ?ncbi_gene_id ?mondo_id WHERE {
SELECT DISTINCT ?mondo_id ?name_en ?name_ja WHERE {
  {
    SELECT DISTINCT ?mondo_url WHERE {
      VALUES ?text { "{{text_list}}" }

      ?as sio:SIO_000628 ?disease ;
          sio:SIO_000628 ?gene .

      ?disease rdf:type ncit:C7057 .
      ?gene rdf:type ncit:C16612 .

      ?gene <http://ddbj.nig.ac.jp/ontologies/nucleotide/gene_synonym> ?gene_synonym ;
            dcterms:identifier ?ncbi_gene_id ;
            sio:SIO_000205 [rdfs:label ?symbol] .

      ?disease rdfs:seeAlso ?mondo_url .
      ?mondo_url rdf:type owl:Class .
      FILTER (
        IF(
          REGEX(?text, "^[0-9]+$"),
          REGEX(?ncbi_gene_id, CONCAT("^", ?text, "$")),
          (REGEX(?symbol, ?text, "i") || REGEX(?gene_synonym, ?text, "i"))
        )
      )
    }
  }

  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/mondo>{
    ?mondo_url rdfs:subClassOf* ?mondo_sup_tier .
    FILTER(CONTAINS(STR(?mondo_sup_tier), "MONDO"))
    ?mondo_sup_tier oboinowl:id ?mondo_id .
    ?mondo_sup_tier rdfs:label ?name_en .
    FILTER (lang(?name_en) = "")
    OPTIONAL { ?mondo_sup_tier rdfs:label ?name_ja FILTER (lang(?name_ja) = "ja") }
  }
} ORDER BY ?mondo_id
```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}

```

`javascript

({text_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++)
    list.push(rows[i].mondo_id.value);

  if(rows){
    dic['input:' + text_list] = Array.from(new Set(list))
  }
  
  return dic
}
```