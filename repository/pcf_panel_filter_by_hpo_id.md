# [PCF] pcf panel filter prioritize phenotype - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0010636 0100021 0002126
  * example: 0003847, 0018096, 0007477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql
* 'https://pubcasefinder-rdf.dbcls.jp/sparql

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
PREFIX HP: <http://purl.obolibrary.org/obo/HP_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT 
#?hgnc_gene_symbol (GROUP_CONCAT(DISTINCT ?hpo; separator=", ") AS ?hpos)
#?hgnc_gene_symbol (COUNT(DISTINCT ?hpo) AS ?hpo_count)
#?hgnc_gene_symbol
?gene_id
WHERE {
  VALUES ?hpo { {{hpo_id_list}} }
  OPTIONAL {?hpo_list rdfs:subClassOf* ?hpo .}
  
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?disease ;
      oa:hasBody ?hpo_list ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  
  BIND (IRI(replace(STR(?disease), 'http://identifiers.org/mim/', 'https://omim.org/entry/')) AS ?exactMatch_disease) .
  ?exactMatch_mondo skos:exactMatch ?exactMatch_disease .
  ?mondo_sub_tier rdfs:subClassOf* ?exactMatch_mondo .
  
  ?mondo_sub_tier skos:exactMatch ?tree_intersection_disease_list .

  BIND (IRI(replace(STR(?tree_intersection_disease_list), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?tree_intersection_disease) .
  ?tree_intersection_disease rdf:type ncit:C7057 .
    
  ?as sio:SIO_000628 ?tree_intersection_disease ;
      sio:SIO_000628 ?gene .
  ?gene rdf:type ncit:C16612 ;
        dcterms:identifier ?gene_id ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
} 
#GROUP BY ?hgnc_gene_symbol
#HAVING (COUNT(DISTINCT ?hpo) = 3)  # 두 개의 HPO가 모두 존재하는 MONDO ID만 선택
ORDER BY DESC (COUNT(DISTINCT ?hpo)) ?hgnc_gene_symbol 
```

## Output
```javascript
({ hpo_id_list, result }) => ({ 
  [hpo_id_list.replace(/obo:/gi, 'HP:').replace(/ /g, '|')]: 
    result.results.bindings.map(r => 'GENEID:' + r.gene_id.value) 
});