# [PCF] Get Panel data by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0013127
  * example: 0009903, 0003847, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/gi,"").replace(/[\s,]/g," ")
   if (mondo_id.match(/[^\s]/)) return mondo_id.split(/\s+/);
  return false;
  //return mondo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT
str(?name_en) as ?name_en
str(?name_ja) as ?name_ja
(GROUP_concat(distinct ?synonym; separator = " | ") as ?synonym)
str(?definition) as ?definition
str(?mondo_id) as ?mondo_id
str(?mondo_url) as ?mondo_url
str(?omim_id) as ?omim_id
str(?omim_url) as ?omim_url
str(?orpha_id) as ?orpha_id
str(?orpha_url) as ?orpha_url
(GROUP_concat(distinct ?icd10_id; separator = " | ") as ?icd10_id)
(GROUP_concat(distinct CONCAT('https://icd.who.int/browse10/2019/en#/', STR(?icd10_url)); separator = " | ") as ?icd10_url)
str(?count) as ?count_gene_id
str(?count_hpo_id) as ?count_hpo_id
#ABS(?omim_hpo) + ABS(?orpha_hpo) as ?count_hpo_id
WHERE {
  
  {{#if mondo_id_list}}
    VALUES ?mondo { {{#each mondo_id_list}} mondo:MONDO_{{this}} {{/each}} }
      {{/if}}
      
      ?mondo sio:SIO_001112 ?count .
      #---------- gene count start
#      {
#        SELECT ?mondo COUNT(DISTINCT ?gene) as ?count WHERE {
#          {
#            SELECT DISTINCT ?mondo ?disease WHERE { 
#              ?mondo_sub_tier rdfs:subClassOf* ?mondo ;
#                              skos:exactMatch ?exactMatch_disease .
#
#              FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
#              BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
#            }
#          }
#          ?as sio:SIO_000628 ?disease ;
#              sio:SIO_000628 ?gene .
#          ?disease rdf:type ncit:C7057 .
#          ?gene rdf:type ncit:C16612 ;
#                dcterms:identifier ?gene_id . 
#        }
#      }
      #---------- gene count end
      
      ?mondo rdfs:label ?name_en .
      optional { ?mondo mondo:IAO_0000115 ?definition }
      optional { ?mondo oboinowl:id ?mondo_id }
      optional { ?mondo oboinowl:hasExactSynonym ?synonym }
      optional { ?mondo oboinowl:hasDbXref ?icd10_id .
                FILTER(CONTAINS(STR(?icd10_id), "ICD10"))
                #BIND (replace(str(?icd10_id), 'ICD10:', 'https://icd.who.int/browse10/2019/en#/') AS ?icd10_url)
                BIND (replace(replace(str(?icd10_id), '[*+]', ''), "ICD10:", "") AS ?icd10_url)
                #BIND (replace(str(?icd10_url), '*:', '') AS ?icd10_url2)
               }
            
      optional { ?disease rdfs:seeAlso ?mondo ;
                          rdfs:label ?name_ja .            
                FILTER (lang(?name_ja) = "ja") 
               }

      optional { ?omim_url rdfs:seeAlso ?mondo ;
                           dcterms:identifier ?omim_id .
                FILTER(CONTAINS(STR(?omim_url), "mim")) 
                {
                  SELECT DISTINCT ?omim_url count(DISTINCT ?omim_hpo) as ?omim_hpo WHERE {
                    ?an rdf:type oa:Annotation ;
                        oa:hasTarget ?omim_url ;
                        oa:hasBody ?omim_hpo ;
                        dcterms:source [dcterms:creator ?creator] .
                    #FILTER(CONTAINS(STR(?omim_url), "mim"))
                    FILTER(?creator NOT IN("Database Center for Life Science"))
                    GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
                      ?omim_hpo rdfs:subClassOf+ ?hpo_category .
                      ?hpo_category rdfs:subClassOf obo:HP_0000118 .
                    }
                  }
                }
               }

      optional { ?orpha_url rdfs:seeAlso ?mondo ;
                            dcterms:identifier ?orpha_id .
                FILTER(CONTAINS(STR(?orpha_url), "ORDO")) 
                {
                  SELECT DISTINCT ?orpha_url count(DISTINCT ?orpha_hpo) as ?orpha_hpo WHERE {
                    ?an rdf:type oa:Annotation ;
                        oa:hasTarget ?orpha_url ;
                        oa:hasBody ?orpha_hpo ;
                        dcterms:source [dcterms:creator ?creator] .
                    #FILTER(CONTAINS(STR(?orpha_url), "ORDO"))
                    FILTER(?creator NOT IN("Database Center for Life Science"))
                    #GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
                      ?orpha_hpo rdfs:subClassOf+ ?hpo_category .
                      ?hpo_category rdfs:subClassOf obo:HP_0000118 .
                    #}
                  }
                }
               }
      BIND(IF(?omim_hpo > 0, IF(?orpha_hpo > 0, ?omim_hpo + ?orpha_hpo, ?omim_hpo), ?orpha_hpo) AS ?count_hpo_id)
      BIND (replace(str(?mondo), 'http://purl.obolibrary.org/obo/MONDO_', 'https://monarchinitiative.org/disease/MONDO:') AS ?mondo_url) 
}
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