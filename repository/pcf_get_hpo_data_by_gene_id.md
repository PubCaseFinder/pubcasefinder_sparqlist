# [PCF] Get HPO data by GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `ncbi_gene_id` NCBI gene ID
  * default: 57514
  * example: 6710, 6521

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) => {
  ncbi_gene_id = ncbi_gene_id.replace(/GENEID:/g,"")
  return ncbi_gene_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>
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
str(?disease) as ?disease
str(?disease_id) as ?disease_id

WHERE { 
	?as sio:SIO_000628 ?disease_url ;
        sio:SIO_000628 ncbigene:{{ncbi_gene_id_list}} .
    
  	?an rdf:type oa:Annotation ;
        oa:hasTarget ?disease_url ;
        oa:hasBody ?hpo_url ;
        dcterms:source [dcterms:creator ?creator] .
  	FILTER(CONTAINS(STR(?disease_url), "mim"))
  	#FILTER(CONTAINS(STR(?disease), "Orphanet"))	
  	?disease_url dcterms:identifier ?disease_id .  
    FILTER(?creator NOT IN("Database Center for Life Science"))
    BIND(IF(regex(?disease_url, 'http://www.orpha.net/ORDO/Orphanet_[0-9]'), 'Orphanet', 'OMIM') AS ?disease)

    GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
      ?hpo_url rdfs:label ?hpo_label_en .
      #?hpo_url <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
      BIND (replace(str(?hpo_url), 'http://purl.obolibrary.org/obo/HP_', 'HP:') AS ?hpo_id)
      ##optional { ?hpo_url obo:IAO_0000115 ?definition . }
      ?hpo_url rdfs:subClassOf+ ?hpo_category .
      ?hpo_category rdfs:subClassOf obo:HP_0000118 .   
      ?hpo_category rdfs:label ?hpo_category_name_en .
    }

    optional { ?hpo_category rdfs:label ?hpo_category_name_ja . FILTER (lang(?hpo_category_name_ja) = "ja") }
    optional { ?hpo_url rdfs:label ?hpo_label_ja . FILTER (lang(?hpo_label_ja) = "ja") }
    
} order by ?disease ?hpo_category ?hpo_id 
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