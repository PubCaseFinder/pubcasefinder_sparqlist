# [PCF] Get HPO data by NANDO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200021
  * example: 1200404, 1201073, 1200010, 120011

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `nando_id_list`
```javascript
({ nando_id }) =>
  nando_id
    .replace(/NANDO:/gi, '')
    .split(/[\s,]+/)
    .filter(Boolean)
    .map(id => `nando:${id}`)
    .join(' ')
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX hoom: <http://www.semanticweb.org/ontology/HOOM#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sio: <http://semanticscience.org/resource/>
SELECT DISTINCT 
str(?hpo_category_name_en) as ?hpo_category_name_en
str(?hpo_category_name_ja) as ?hpo_category_name_ja
str(?hpo_id) as ?hpo_id
str(?hpo_url) as ?hpo_url
str(?hpo_label_en) as ?hpo_label_en
str(?hpo_label_ja) as ?hpo_label_ja
#str(?definition) as ?definition
str(?frequency) as ?frequency
WHERE 
{
  VALUES ?nando_input { {{nando_id_list}}  }
  ?nando_input skos:exactMatch ?mondo_exactMatch .
  ?disease_url rdfs:seeAlso ?mondo_exactMatch .
  ?an rdf:type oa:Annotation ;
       oa:hasBody ?hpo_url ;
       oa:hasTarget ?disease_url ;
       dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo_url rdfs:label ?hpo_label_en .
    #?hpo_url oboinowl:id ?hpo_id .
    #optional { ?hpo_url obo:IAO_0000115 ?definition . }
    ?hpo_url rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:0000118 . 
    ?hpo_category rdfs:label ?hpo_category_name_en .
  }
  optional { ?an hoom:with_frequency [rdfs:label ?frequency] FILTER(LANG(?frequency) = "en") FILTER(LANG(?frequency) = "en") }
  optional { ?hpo_url rdfs:label ?hpo_label_ja . FILTER (lang(?hpo_label_ja) = "ja") }
  optional { ?hpo_category rdfs:label ?hpo_category_name_ja . FILTER (lang(?hpo_category_name_ja) = "ja") }  
  #?hpo <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
  BIND (IRI(replace(STR(?hpo_url), 'http://purl.obolibrary.org/obo/HP_', 'HP:')) AS ?hpo_id)
  
#  optional {
#    ?hpo rdfs:label ?hpo_en, ?hpo_ja . 
#    FILTER (lang(?hpo_en) = "") .
#    FILTER (lang(?hpo_ja) = "ja") .
#  }
#  #association
#  ?as sio:SIO_000628 ?disease_url ;
#      sio:SIO_000628 ?gene .
#  ?gene rdf:type ncit:C16612 ;
#        dcterms:identifier ?gene_id ;
#        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
}
order by ?hpo_id
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