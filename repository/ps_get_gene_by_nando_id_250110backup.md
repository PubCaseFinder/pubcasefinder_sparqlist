# [PCF] FILTER: GET GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200005
  * example: 1200009, 2200865

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
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX dcterm: <http://purl.org/dc/terms/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
SELECT 
?hgnc_gene_symbol 
?gene_id
(GROUP_concat(distinct ?disease_info; separator = " | ") as ?disease_info)
(GROUP_concat(distinct ?disease_info_ja; separator = " | ") as ?disease_info_ja)
(GROUP_concat(distinct ?source_name; separator = " | ") as ?source_name)
(GROUP_concat(distinct ?inheritance_en; separator = ", ") as ?inheritance_en)
(GROUP_concat(distinct ?inheritance_ja; separator = ", ") as ?inheritance_ja)
WHERE {
  {
    SELECT DISTINCT ?disease WHERE {
      VALUES ?nando { {{#each nando_id_list}} nando:{{this}} {{/each}} }
      ?nando a owl:Class .
      #?nando skos:closeMatch|skos:exactMatch ?mondo .
      ?nando skos:exactMatch ?mondo .
      ?mondo oboinowl:id ?mondo_id .
      #?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
      ?mondo_sub_tier rdfs:subClassOf* ?mondo ;
                      skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      #BIND(IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
      BIND(IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .
      # 위의 BIND 부분은 OMIM의 주소가 변경된 문제로 최신 RDF로 변환 하면 삭제 해도 되는 부분
    }
  }
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene ;
      dcterm:source ?source .
  ?disease rdf:type ncit:C7057 ;
           dcterm:identifier ?disease_id ;
           rdfs:seeAlso [rdfs:label ?disease_name] .
  ?gene rdf:type ncit:C16612 ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] ;
        dcterm:identifier ?gene_id . 
  
  OPTIONAL { 
    ?disease :hasInheritance ?inheritance .
    ?inheritance rdfs:label ?inheritance_en, ?inheritance_ja .
    FILTER (lang(?inheritance_en) = "") . 
    FILTER (lang(?inheritance_ja) = "ja") . 
  }
  
  BIND(CONCAT(?disease_name, IF(CONTAINS(STR(?disease), "Orphanet"), ", ORPHA:", ", OMIM:"), ?disease_id) AS ?disease_info)
# Start 20240829 Changes due to the addition of MONDO Japanese labels
  FILTER (lang(?disease_name) = "")
  OPTIONAL { ?disease dcterm:identifier ?disease_id ;
                      rdfs:seeAlso [rdfs:label ?disease_name_ja] 
                      BIND(CONCAT(?disease_name_ja, IF(CONTAINS(STR(?disease), "Orphanet"), ", ORPHA:", ", OMIM:"), ?disease_id) AS ?disease_info_ja)
                      FILTER (lang(?disease_name_ja) = "ja")
           }
# End
  BIND(IF(STR(?source) = 'http://www.orphadata.org/data/xml/en_product6.xml', 'Orphadata',
       IF(STR(?source) = 'ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen', 'OMIM', 'GenCC')) AS ?source_name)
} order by ?hgnc_gene_symbol
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