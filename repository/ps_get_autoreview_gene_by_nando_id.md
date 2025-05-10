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
SELECT DISTINCT
?ncbi_gene_id
?hgnc_gene_symbol
?rating
?source
?gencc_url
?nando_ja ?nando_en ?nando_id
?mondo_ja
?mondo_en
?mondo_sub_tier AS ?mondo_url
?moi_ja
?moi_en
WHERE { 
  {
    SELECT DISTINCT ?mondo_sub_tier ?nando_sub_tier WHERE {
      VALUES ?nando_input { nando:{{nando_id_list}} }
      optional {?nando_sub_tier nando:memberOf | rdfs:subClassOf* ?nando_input . }
      ?nando_sub_tier skos:exactMatch ?mondo_exactMatch .
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_exactMatch .
    }
  }
  
  ?mondo_sub_tier skos:exactMatch ?exactMatch_disease .
  FILTER(CONTAINS(STR(?exactMatch_disease), "/omim.org/entry/") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
  BIND(IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .
  OPTIONAL 
  {
    ?nando skos:exactMatch ?mondo_sub_tier ;
           dcterms:identifier ?nando_id ;
           rdfs:label ?nando_ja ;
           rdfs:label ?nando_en.
    
    FILTER(lang(?nando_ja) = "ja")
    FILTER(lang(?nando_en) = "en")
    FILTER(CONTAINS(STR(?nando), "NANDO_1"))
  }
  OPTIONAL {
    ?mondo_sub_tier rdfs:label ?mondo_en .
    FILTER (lang(?mondo_en) = "") . 
  }
  OPTIONAL {
    ?mondo_sub_tier rdfs:label ?mondo_ja .
    FILTER (lang(?mondo_ja) = "ja") .
  }
  #association
  #?as sio:SIO_000628 ?exactMatch_disease ;
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene ;
      dcterms:source ?source_url .
  FILTER (?source_url != <https://search.thegencc.org/download/action/submissions-export-csv>)
  
  #?exactMatch_disease rdf:type ncit:C7057 . omim이 완벽하지 못하여 생기는 문제
  #gene info
  ?gene rdf:type ncit:C16612 ;
        dcterms:identifier ?ncbi_gene_id ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  
  OPTIONAL {
    #GenCC source
    ?source_url obo:IAO_0000114 ?gencc_rating ;
               :hasInheritance ?moi ;
               dcterms:creator ?submitter .

    #mode of inheritance
    ?moi rdfs:label ?moi_en ;
         rdfs:label ?moi_ja .
    FILTER (lang(?moi_en) = "") .
    FILTER (lang(?moi_ja) = "ja") .
  }
  BIND(IF(STR(?source_url) = 'http://www.orphadata.org/data/xml/en_product6.xml', ?exactMatch_disease,
            IF(STR(?source_url) = 'ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen', ?exactMatch_disease, ?source_url)) AS ?gencc_url)
  BIND(IF(STR(?source_url) = 'http://www.orphadata.org/data/xml/en_product6.xml', 'Orphadata',
            IF(STR(?source_url) = 'ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen', 'OMIM', CONCAT(?submitter, " (GenCC)"))) AS ?source)
  BIND(IF(STR(?source_url) = 'http://www.orphadata.org/data/xml/en_product6.xml', 'Supportive',
            IF(STR(?source_url) = 'ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen', 'Supportive', ?gencc_rating)) AS ?rating)
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