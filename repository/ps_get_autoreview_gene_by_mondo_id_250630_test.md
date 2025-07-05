# [PCF] FILTER: GET Auto review GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0008199
  * example: 1200021, 1200220, 1200477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql/

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
PREFIX mondo: <http://purl.obolibrary.org/obo/MONDO_>
SELECT DISTINCT
?ncbi_gene_id
?hgnc_gene_symbol
?rating
?source
?source_url
?mondo_ja
?mondo_en
?mondo_sub_tier AS ?mondo_url
?moi_ja
?moi_en
?reference_mondo_id
WHERE { 
  {
    SELECT DISTINCT ?mondo_sub_tier WHERE {
      VALUES ?mondo_input { mondo:{{mondo_id_list}} }
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_input .
      FILTER(CONTAINS(STR(?mondo_sub_tier), "MONDO"))
    }
  }
  ?mondo_sub_tier oboinowl:id ?reference_mondo_id .
  ?mondo_sub_tier skos:exactMatch ?exactMatch_disease .
  FILTER(CONTAINS(STR(?exactMatch_disease), "/omim.org/entry/") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
  BIND(IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .

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
      dcterms:source ?source_uri .
  FILTER (?source_uri != <https://search.thegencc.org/download/action/submissions-export-csv>)
  
  #mode of inheritance
  OPTIONAL {
    ?disease :hasInheritance ?inheritance .
    ?inheritance rdfs:label ?moi_en, ?moi_ja .
    FILTER (lang(?moi_en) = "" && lang(?moi_ja) = "ja") .
  }
  #?exactMatch_disease rdf:type ncit:C7057 . omim이 완벽하지 못하여 생기는 문제
  #gene info
  ?gene rdf:type ncit:C16612 ;
        dcterms:identifier ?ncbi_gene_id ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  
  OPTIONAL {
    #GenCC source
    ?source_uri obo:IAO_0000114 ?gencc_rating ;
    #            :hasInheritance ?moi ;
                dcterms:creator ?submitter .
    #mode of inheritance
    #?moi rdfs:label ?moi_en ;
    #     rdfs:label ?moi_ja .
    #FILTER (lang(?moi_en) = "") .
    #FILTER (lang(?moi_ja) = "ja") .
  }
  BIND(IF(CONTAINS(STR(?source_uri), "orphadata"), ?exactMatch_disease,
          IF(CONTAINS(STR(?source_uri), "mim2gene_medgen"), ?exactMatch_disease, ?source_uri)) AS ?source_url)

  BIND(IF(CONTAINS(STR(?source_uri), "orphadata"), "Orphadata",
          IF(CONTAINS(STR(?source_uri), "mim2gene_medgen"), "OMIM", CONCAT(?submitter, " (GenCC)"))) AS ?source)

  BIND(IF(CONTAINS(STR(?source_uri), "orphadata") || CONTAINS(STR(?source_uri), "mim2gene_medgen"),
          "Supportive", ?gencc_rating) AS ?rating)
}
order by ?hgnc_gene_symbol
```

## Output
```javascript
({ result }) => {
  const grouped = {};

  result.results.bindings.forEach(data => {
    const entry = Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});

    const mondoId = entry.reference_mondo_id;

    if (!grouped[mondoId]) {
      grouped[mondoId] = [];
    }
    grouped[mondoId].push(entry);
  });

  return grouped;
}
```
