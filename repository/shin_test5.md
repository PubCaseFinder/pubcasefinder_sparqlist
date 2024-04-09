# Not in matched phenotype Ids
## a
*  b
*  c

## Parameters

* `omim_id`
  * default: 263750
  * example: 263750, 154400, 214800, 105650
* `matched_phenotype_Ids`
  * default: 0001510, 0000347
  * example: 0001510, 0000347, 0000698, 0000767, 0000204, 00009778, 0000028, 0001374, 0000369, 0003022, 0000007, 0000077, 0000453, 0002984, 0000175, 0000062, 0001159, 0003422, 0002021, 0008897, 0000378, 0009778, 0000054, 0002946, 0000625, 0000494, 0002558, 0001760, 0005211, 0002974
* `rdf_portal`
  * default: https://integbio.jp/rdf/sparql  

## Endpoint

{{ rdf_portal }}

## `omim_id_list`
```javascript
({omim_id}) => {
  omim_id = 'mim:' + omim_id.replace(/[\s,]+/g," mim:")
  return omim_id;
}
```

## `matched_phenotype_id_list`
```javascript
({matched_phenotype_Ids}) => {
  matched_phenotype_Ids = 'obo:HP_' + matched_phenotype_Ids.replace(/[\s,]+/g,", obo:HP_")
  return matched_phenotype_Ids;

//({matched_phenotype_Ids}) => {
  //matched_phenotype_Ids = 'obo:HP_' + matched_phenotype_Ids.replace(/[\s,]+/g,", obo:HP_")
  //return matched_phenotype_Ids;
  //matched_phenotype_Ids = matched_phenotype_Ids.replace(/,/g," ")
  //if (matched_phenotype_Ids.match(/[^\s]/)) return matched_phenotype_Ids.split(/\s+/);
  //return false;
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

SELECT DISTINCT
?hp
#str(?hp_ID) as ?HPO_ID
str(?disease_name) as ?Disease_Name 
str(?overview) as ?Overview 
str(?mondo_ID) as ?MONDO_ID
?gene_ID 

WHERE {
  
  {{#if omim_id_list}}
    VALUES ?mim_id { {{omim_id_list}} }
  {{/if}}
    
    GRAPH <https://pubcasefinder.dbcls.jp/rdf> {
      ?mim_id rdfs:seeAlso ?mondo .
    }
    
    GRAPH <http://integbio.jp/rdf/ontology/mondo> { 
      ?mondo obo:IAO_0000115 ?overview ;
             <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_ID ; 
             rdfs:label ?disease_name .
    }
    
    # Causative Gene
    GRAPH <https://pubcasefinder.dbcls.jp/rdf> {
      ?as sio:SIO_000628 mim:263750 ;
          sio:SIO_000628 ?gene .
      ?gene rdf:type ncit:C16612 ;
            dcterms:identifier ?gene_ID.
    }
    
    # Mismatched Phenotype
    {
      SELECT ?hp ?matched_phenotypes_uri
      WHERE { 
        GRAPH <https://pubcasefinder.dbcls.jp/rdf> { 
          ?s rdf:type oa:Annotation ;
               oa:hasTarget mim:263750 ;
               oa:hasBody ?hp .
        }

        {{#if matched_phenotype_id_list}}
  			FILTER (?hp NOT IN( {{matched_phenotype_id_list}} ))
		{{/if}}
 
        
      }
    }
}
```