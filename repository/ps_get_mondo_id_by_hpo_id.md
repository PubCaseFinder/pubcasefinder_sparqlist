# FILTER: Get GENE ID by HPO ID - https://pubcasefinder.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0010636 0100021 0002126
  * example: 0010636, 0100021, 0002126
* `mode` set
  * default: 
  * example: union intersection
* `match` hpo count
  * default: 3
  * example: 1, 2, 3
## Endpoint
https://pubcasefinder.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => 
  'obo:' + hpo_id.replace(/HP:/g, '').trim().replace(/[\s,]+/g, ' obo:');
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>

SELECT DISTINCT 
?mondo_id (COUNT(DISTINCT ?hpo) AS ?hpo_count)
WHERE {
  VALUES ?hpo { {{hpo_id_list}} }

  OPTIONAL { ?hpo_list rdfs:subClassOf* ?hpo . }

  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?disease ;
      oa:hasBody ?hpo_list ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))

  BIND(IRI(REPLACE(STR(?disease), "http://identifiers.org/mim/|http://identifiers.org/omim/", "https://omim.org/entry/")) AS ?exactMatch_disease)
  ?exactMatch_mondo skos:exactMatch ?exactMatch_disease .
  ?mondo_sub_tier rdfs:subClassOf* ?exactMatch_mondo .
  ?mondo_sub_tier skos:exactMatch ?tree_intersection_disease_list .
  ?mondo_sub_tier oboinowl:id ?mondo_id 
                .
  BIND(IRI(REPLACE(STR(?tree_intersection_disease_list), "https://omim.org/entry/|http://identifiers.org/omim/", "http://identifiers.org/mim/")) AS ?tree_intersection_disease)
  ?tree_intersection_disease rdf:type ncit:C7057 .

#  ?as sio:SIO_000628 ?tree_intersection_disease ;
#      sio:SIO_000628 ?gene .
#  ?gene rdf:type ncit:C16612 .
}
GROUP BY ?mondo_id
{{#if mode}}
  HAVING (COUNT(DISTINCT ?hpo) >= {{match}})
{{/if}}
ORDER BY DESC(?hpo_count)
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