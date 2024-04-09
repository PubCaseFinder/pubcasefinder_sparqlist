# Get OMIM data by OMIM ID test
## a
*  b
*  c

## Parameters

* `omim_id`
  * default: 263750, 154400, 214800, 105650, 609945, 268300, 219000, 143095, 615162, 122470
  * example: 263750, 154400, 214800, 105650, 609945, 268300, 219000, 143095, 615162, 122470
* `rdf_portal`
  * default: https://integbio.jp/rdf/sparql  
* `mode`
  * example: ja
## Endpoint

{{ rdf_portal }}

## `omim_id_list`
```javascript
({omim_id}) => {
  omim_id = 'mim:' + omim_id.replace(/[\s,]+/g," mim:")
  return omim_id;
}
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX nando: <http://nanbyodata.jp/ontology/nando#>
SELECT DISTINCT
#str(?hp_ID) as ?HPO_ID
str(?mim_id) as ?OMIM_ID
str(?disease_name) as ?Disease_Name 
str(?description) as ?Description 
str(?mondo_ID) as ?MONDO_ID
?gene_ID 
{{#if mode}}
?disease_name_ja
{{/if}}
WHERE {

  {{#if omim_id_list}}
	VALUES ?mim_id { {{omim_id_list}} }
  {{/if}}
	
	OPTIONAL {
		?mim_id rdfs:seeAlso ?mondo .

      	?mim_id nando:hasinheritance ?inheritance .
      {{#if mode}}
        ?mim_id rdfs:label ?disease_name_ja .
    	FILTER (lang(?inheritance) = "ja") 
      {{else}}
        FILTER (lang(?inheritance) = "en") 
      {{/if}}
        
		?mondo obo:IAO_0000115 ?description . 
		?mondo <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_ID . 
		?mondo rdfs:label ?disease_name .

		?as sio:SIO_000628 ?mim_id ;
			sio:SIO_000628 ?gene .
		?gene rdf:type ncit:C16612 ;
			dcterms:identifier ?gene_ID.

	}
}
```