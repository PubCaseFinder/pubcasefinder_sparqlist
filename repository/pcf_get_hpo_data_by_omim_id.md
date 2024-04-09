# [PCF] Get HPO data by OMIM ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `omim_id` OMIM ID
  * default: 607341
  * example: 263750, 612158, 154400, 214800, 105650

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `omim_id_list`
```javascript
({omim_id}) => {
  omim_id = omim_id.replace(/OMIM:/g,"")
  return omim_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT DISTINCT
str(?hpo_category_name_en) as ?hpo_category_name_en
str(?hpo_category_name_ja) as ?hpo_category_name_ja
str(?hpo_id) as ?hpo_id
str(?hpo_url) as ?hpo_url
str(?hpo_label_en) as ?hpo_label_en
str(?hpo_label_ja) as ?hpo_label_ja
str(?definition) as ?definition

WHERE { 
    VALUES ?mim_id { mim:{{omim_id_list}} }

    ?an rdf:type oa:Annotation ;
        oa:hasTarget ?mim_id ;
        oa:hasBody ?hpo_url ;
        dcterms:source [dcterms:creator ?creator] .
    FILTER(CONTAINS(STR(?mim_id), "mim"))
    FILTER(?creator NOT IN("Database Center for Life Science"))

    GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
      ?hpo_url rdfs:label ?hpo_label_en .
      #?hpo_url <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
      BIND (replace(str(?hpo_url), 'http://purl.obolibrary.org/obo/HP_', 'HP:') AS ?hpo_id)
      optional { ?hpo_url obo:IAO_0000115 ?definition . }
      ?hpo_url rdfs:subClassOf+ ?hpo_category .
      ?hpo_category rdfs:subClassOf obo:HP_0000118 .   
      ?hpo_category rdfs:label ?hpo_category_name_en .
    }

    optional { ?hpo_category rdfs:label ?hpo_category_name_ja . FILTER (lang(?hpo_category_name_ja) = "ja") }
    optional { ?hpo_url rdfs:label ?hpo_label_ja . FILTER (lang(?hpo_label_ja) = "ja") }
    
} order by ?hpo_category ?hpo_id
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