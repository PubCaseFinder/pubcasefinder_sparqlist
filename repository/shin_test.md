# Test
## a
*  b
*  c

## Parameters

* `omim_id`
  * default: 263750
  * example: 263750, 154400, 214800, 105650
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

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX egi: <http://identifiers.org/ncbigene/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT Distinct(STR(?first_tier_label_str)) as ?first_tier_label ?first_tier STR(?hp_label) AS ?HPO_label ?hp count(distinct ?sub_tier) as ?sub_count
#SELECT Distinct ?sub_tier ?hp ?first_tier ?first_tier_label_str  #count(distinct ?sub) as ?sub_count
WHERE{
  {
    SELECT ?hp ?first_tier
	WHERE { 
      {{#if omim_id_list}}
		VALUES ?mim_id { {{omim_id_list}} }
	  {{/if}}
        
      
      ?s rdf:type oa:Annotation ;
         oa:hasTarget ?mim_id ; #mim:263750 ; #?mim_id ;
         oa:hasBody ?hp .
    
       #values ?hp { obo:HP_0000054 obo:HP_0000204 } #obo:HP_0000028  }
      ?hp rdfs:label ?hp_label .
      FILTER REGEX(?hp_label, "[A-Z]")
      optional { ?first_tier rdfs:subClassOf ?hp .} 
      #?first_tier rdfs:subClassOf <http://purl.obolibrary.org/obo/HP_0000118> .
      #<http://purl.obolibrary.org/obo/HP_0003422> .
      #?first_tier rdfs:subClassOf <http://purl.obolibrary.org/obo/HP_0000204> .
    }
  }
  
  #FILTER (lang(?hp_label) != "jp")
  #FILTER (lang(?hp_label) != "en")
  #FILTER REGEX(?hp_label, "[A-Z]")
  ?hp rdfs:label ?hp_label .
  FILTER REGEX(?hp_label, "[A-Z]")
  OPTIONAL {
    		?sub_tier rdfs:subClassOf* ?first_tier. 
            ?first_tier rdfs:label ?first_tier_label_str. 
            FILTER REGEX(?first_tier_label_str, "[A-Z]")
           }

  #FILTER (lang(?first_tier_label_str) != "jp")
  
 }
#group by ?first_tier_label_str
order by ?hp desc(?sub_count)

```