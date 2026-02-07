# FILTER: GET OMIM IDs by multi NCBI gene ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `ncbi_gene_id` NCBI gene ID
  * default: 57514 6521
  * example: 6710 6521

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `ncbi_gene_id_list`
```javascript
({ ncbi_gene_id }) =>
  'ncbigene:' + ncbi_gene_id.replace(/GENEID:/g, '').replace(/[\s,]+/g, ' ncbigene:')
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX sio: <http://semanticscience.org/resource/>

SELECT DISTINCT ?nando_id ?name_en ?name_ja
WHERE {
  VALUES ?ncbi_gene_url { {{ncbi_gene_id_list}} }

  ?as rdf:type sio:SIO_000983 ;
      sio:SIO_000628 ?ncbi_gene_url ;
      sio:SIO_000628 ?disease_url .

  ?ncbi_gene_url rdf:type ncit:C16612 .
  ?disease_url rdf:type ncit:C7057 .
  
  BIND(IRI(replace(STR(?disease_url), 'http://identifiers.org/mim/', 'https://omim.org/entry/')) AS ?exactMatch_disease ) .
  
  ?mondo_sub_tier skos:exactMatch ?exactMatch_disease  .
  ?mondo_sub_tier rdfs:subClassOf* ?mondo_exactMatch .
  ?nando_sub_tier skos:exactMatch ?mondo_exactMatch .
  optional {?nando_sub_tier nando:memberOf | rdfs:subClassOf* ?nando_id . }
  ?nando_id a owl:Class .
  FILTER( REGEX(STR(?nando_id), "NANDO_(12|3)") )
  OPTIONAL { ?nando_id rdfs:label ?name_en . FILTER(lang(?name_en) = "en") }
  OPTIONAL { ?nando_id rdfs:label ?name_ja . FILTER(lang(?name_ja) = "ja") }
}
```

## `return`
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