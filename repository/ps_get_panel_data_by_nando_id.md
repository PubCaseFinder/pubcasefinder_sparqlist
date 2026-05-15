# [PCF] Get Panel data by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200001
  * example: 1200030, 1200002, 1200028, 1200029, 1200043, 1200192, 1200208, 1200258, 1200286
* `sort` name_en/name_ja/name_hira/count
  * default: name_en
  * example: name_en, name_ja, name_hira
* `direction` ASC/DESC
  * default: ASC
  * example: ASC, DESC

## Endpoint
https://pubcasefinder.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/gi,"").replace(/[\s,]/g," ")
   if (nando_id.match(/[^\s]/)) return nando_id.split(/\s+/);
  return false;
  //return mondo_id;
}
```

## `orderby`
```javascript
({sort, direction}) => {
  if (!sort) return;
  var result;
  switch(direction){
    case 'ASC':
      result = '?' + sort;
      break;

    case 'DESC':
      result = 'DESC(?' + sort + ')';
      break;

    default:
      break;
  }
  return result;
}
```

## `result` 
```sparql
PREFIX : <http://nanbyodata.jp/ontology/nando#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
prefix mo: <http://med2rdf/ontology/medgen#>


SELECT DISTINCT 
?label_hira
?label_ja
?label_en
(GROUP_concat(distinct ?synonym_ja; separator = " | ") as ?synonym_ja)
(GROUP_concat(distinct ?synonym_en; separator = " | ") as ?synonym_en)
?notification_number
?mhlw_url
?source
?nanbyou_url
STR(?nando) AS ?nando_url
?description
?mondo_description
?medgen_definition
(GROUP_concat(distinct ?orphanet_id; separator = " | ") as ?orphanet_id)
(GROUP_concat(distinct CONCAT('http://www.orpha.net/ORDO/Orphanet_', STR(?orphanet_url)); separator = " | ") as ?orphanet_url)
(GROUP_concat(distinct ?omim_id; separator = " | ") as ?omim_id)
(GROUP_concat(distinct CONCAT('https://omim.org/entry/', STR(?omim_url)); separator = " | ") as ?omim_url)
?kegg_id
?kegg_url
(GROUP_concat(distinct ?icd10_id; separator = " | ") as ?icd10_id)
(GROUP_concat(distinct CONCAT('https://icd.who.int/browse10/2019/en#/', STR(?icd10_url)); separator = " | ") as ?icd10_url)
?count
#str(?count_hpo_id) as ?count_hpo_id
#COUNT(DISTINCT ?hpo) as ?count_hpo_id
?count_hpo_id
WHERE {
  VALUES ?nando { {{#each nando_id_list}} nando:{{this}} {{/each}} }
  
  ?nando a owl:Class .
  
  OPTIONAL { ?nando rdfs:label ?label_hira . FILTER(LANG(?label_hira) = 'ja-hira') }
  OPTIONAL { ?nando rdfs:label ?label_ja . FILTER(LANG(?label_ja) = 'ja') }
  OPTIONAL { ?nando rdfs:label ?label_en . FILTER(LANG(?label_en) = 'en') }
  
  OPTIONAL { ?nando skos:altLabel ?synonym_ja . FILTER(LANG(?synonym_ja) = 'ja') }
  OPTIONAL { ?nando skos:altLabel ?synonym_en . FILTER(LANG(?synonym_en) = 'en') }
  
  OPTIONAL { ?nando nando:hasNotificationNumber ?notification_number . }
  OPTIONAL { ?nando rdfs:seeAlso ?mhlw_url . FILTER(CONTAINS(STR(?mhlw_url), "mhlw")) }
  OPTIONAL { ?nando dcterms:source ?source }
  OPTIONAL { ?nando rdfs:seeAlso ?nanbyou_url . FILTER(CONTAINS(STR(?nanbyou_url), "nanbyou")) }
  OPTIONAL { ?nando dcterms:description ?description . }
  OPTIONAL {
    ?nando skos:exactMatch ?mondo .
    ?mondo obo:IAO_0000115 ?mondo_description .
  }
  
  OPTIONAL {
    ?nando skos:exactMatch ?mondo .
    ?mgconso rdfs:seeAlso ?mondo .
    ?concept mo:mgconso ?mgconso ;
             skos:definition ?medgen_definition .
  }
  
  OPTIONAL {
    ?nando skos:exactMatch ?mondo .
    ?mondo oboinowl:hasDbXref ?icd10_id .
    FILTER(CONTAINS(STR(?icd10_id), "ICD10:"))
    #BIND (replace(replace(str(?icd10_id), '^ICD10[^:]+:', ''), 'ICD10:', '') AS ?icd10_url)
    #BIND(REPLACE(STR(?icd10_id), "ICD10", "") AS ?icd10_url)
  }

  OPTIONAL {
    ?nando skos:exactMatch ?mondo .
    ?mondo oboinowl:hasDbXref ?orphanet_id .
    FILTER(CONTAINS(STR(?orphanet_id), "Orphanet"))
    BIND(REPLACE(STR(?orphanet_id), "Orphanet:", "") AS ?orphanet_url)
  }

  OPTIONAL {
    ?nando skos:exactMatch ?mondo .
    ?mondo oboinowl:hasDbXref ?omim_id .
    FILTER(CONTAINS(STR(?omim_id), "OMIM:"))
    BIND(REPLACE(STR(?omim_id), "OMIM:", "") AS ?omim_url)
  }
    
  OPTIONAL { 
    ?nando rdfs:seeAlso ?kegg_url . FILTER(CONTAINS(STR(?kegg_url), 'kegg')) 
    BIND(REPLACE(STR(?kegg_url), 'https://www.kegg.jp/dbget-bin/www_bget\\?ds_ja:', '') AS ?kegg_id)
  }
    
  # HPO count
  OPTIONAL {
    {
      SELECT ?nando COUNT(DISTINCT ?hpo) as ?count_hpo_id WHERE {
        ?nando skos:exactMatch ?mondo .
        ?disease_url rdfs:seeAlso ?mondo .
        ?dpa rdf:type oa:Annotation ;
             oa:hasBody ?hpo ;
             oa:hasTarget ?disease_url ;
             dcterms:source [dcterms:creator ?creator] .
        FILTER(?creator NOT IN("Database Center for Life Science"))
        GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
          ?hpo rdfs:subClassOf+ ?hpo_category .
          ?hpo_category rdfs:subClassOf obo:HP_0000118 .   
        }
        # Disease Gene Association
        #    OPTIONAL {
        #      ?as sio:SIO_000628 ?disease_url ;
        #          sio:SIO_000628 ?gene .
        #      ?gene rdf:type ncit:C16612 .
        #      ?gene rdfs:label ?gene_symbol .
        #    }
      }
    }
  }
    
  OPTIONAL {
    #?nando skos:exactMatch ?mondo .
    {
      SELECT ?nando COUNT(DISTINCT ?gene) as ?count WHERE {
        {
          OPTIONAL {
            VALUES ?nando { {{#each nando_id_list}} nando:{{this}} {{/each}} }
              ?as sio:SIO_000628 ?nando ;
                  sio:SIO_000628 ?gene .
              ?nando a owl:Class .
              ?gene rdf:type ncit:C16612 .
          }
        }
        UNION
        {
          {
            SELECT DISTINCT ?nando ?disease WHERE { 
              ?nando_sub_tier nando:memberOf | rdfs:subClassOf* ?nando .
              ?nando_sub_tier skos:exactMatch ?mondo_exactMatch .
              ?mondo_sub_tier rdfs:subClassOf* ?mondo_exactMatch .
              ?mondo_sub_tier skos:exactMatch ?exactMatch_disease .

              #?mondo_sub_tier rdfs:subClassOf* ?mondo ;
              #                skos:exactMatch ?exactMatch_disease .

              FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
              #BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
              BIND (IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .
            }
          }
          ?as sio:SIO_000628 ?disease ;
              sio:SIO_000628 ?gene .
          ?disease rdf:type ncit:C7057 .
          ?gene rdf:type ncit:C16612 ;
                dcterms:identifier ?gene_id .
        }
      }
    }
  }
}
{{#if orderby}}
ORDER BY {{orderby}}
{{/if}}
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