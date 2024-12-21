# [PCF] FILTER: GET Auto review GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200021
  * example: 1200021, 1200220, 1200477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql/

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/gi,"").replace(/[\s,]/g," ")
   if (nando_id.match(/[^\s]/)) return nando_id.split(/\s+/);
  return false;
  //return mondo_id;
}
```

## `result` 
```sparql
PREFIX : <http://nanbyodata.jp/ontology/nando#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT 
?ncbi_gene_id
?hgnc_gene_symbol
?rating
CONCAT(?submitter, " (GenCC)") AS ?source
?mondo_ja
?mondo_en
#CONCAT(?mondo_en, ", ", ?disease) AS ?disease
?nando_ja
?nando_en
WHERE {
  {
    SELECT DISTINCT ?exactMatch_disease ?mondo_ja ?mondo_en ?nando_ja ?nando_en WHERE {
      VALUES ?nando { nando:{{nando_id_list}} }
      ?nando a owl:Class ;
             rdfs:label ?nando_label_ja ;
             rdfs:label ?nando_label_en ;
             dcterms:identifier ?nando_id .
      FILTER(lang(?nando_label_ja) = "ja")
      FILTER(lang(?nando_label_en) = "en")
      BIND(CONCAT(?nando_label_ja, ", ", ?nando_id) AS ?nando_ja)
      BIND(CONCAT(?nando_label_en, ", ", ?nando_id) AS ?nando_en)
      
      ?nando skos:exactMatch ?mondo .
      ?mondo rdfs:label ?mondo_en ;
              rdfs:label ?mondo_ja ;
             oboinowl:id ?mondo_id .
      FILTER (lang(?mondo_en) = "")
      FILTER (lang(?mondo_ja) = "ja") .
      ?mondo_sub_tier rdfs:subClassOf* ?mondo ;
                      skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "/omim.org/entry/") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      
    }
  }
  ?as sio:SIO_000628 ?exactMatch_disease ;
      sio:SIO_000628 ?gene ;
      dcterms:source [      
        obo:IAO_0000114 ?rating ;
        :hasInheritance ?moi ;
        dcterms:creator ?submitter ;
      ] .
  #?exactMatch_disease rdf:type ncit:C7057 .
  ?gene rdf:type ncit:C16612 ;
        dcterms:identifier ?ncbi_gene_id ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  
  BIND (IRI(replace(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'OMIM:'), 'http://www.orpha.net/ORDO/Orphanet_', 'Orphanet:')) AS ?disease) .
}
order by ?hgnc_gene_symbol
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