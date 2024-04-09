# Get HPO data by MONDO ID

## Parameters

* `mondo_id` MONDO ID
  * default: 0007739
  * example: 0007739, 0009688

## Endpoint

https://integbio.jp/rdf/sparql

## Endpoint

https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = 'obo:MONDO_' + mondo_id.replace(/[\s,]+/g," obo:MONDO_")
  return mondo_id;
}
```

## `result` retrieve phenotypes associated with the MONDO ID

```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX dcterms: <http://purl.org/dc/terms/>

SELECT DISTINCT
str(?nando_identifier) as ?nando_identifier
str(?hpo_id) as ?hpo_id
WHERE { 
  {
    SELECT DISTINCT ?nando_id ?mondo_id ?nando_identifier WHERE { 
      ?nando_id nando:hasNotificationNumber ?nn.
      ?nando_id skos:closeMatch ?mondo_id.
      ?nando_id dcterms:identifier ?nando_identifier .
    }
  }
  
  ?an rdf:type oa:Annotation ;
      oa:hasTarget [rdfs:seeAlso ?mondo_id] ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
    
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
  optional { ?hpo_category rdfs:subClassOf obo:HP_0000118 . }
  ?hpo_url rdfs:subClassOf+ ?hpo_category .
  ?hpo_url rdfs:label ?hpo_label_en .
  ?hpo_url <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
  }
    
  optional { ?hpo_url rdfs:label ?hpo_label_ja . FILTER (lang(?hpo_label_ja) = "ja") }
} order by ?nando_id ?mondo_id $hpo_id
```

## `return`
```javascript

({result})=>{ 
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    if (rows[i].nando_identifier.value in dic)
    {
      dic[rows[i].nando_identifier.value].push(rows[i].hpo_id.value);
    }
    else
    {
      dic[rows[i].nando_identifier.value] = [];
      dic[rows[i].nando_identifier.value].push(rows[i].hpo_id.value);
    };
  }

  return dic
};

```
## Description
- 過去のUIで使用していたSPARQListで現在は使われていません。（編集：高月）





