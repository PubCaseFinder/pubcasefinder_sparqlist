# [PCF] FILTER: GET Auto review GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200477
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
?source_url
?nando_ja ?nando_en ?nando_id
?mondo_ja
?mondo_en
?mondo_url
?moi_ja
?moi_en
?nando_sub_tier
?reference_nando_id
WHERE { 
  {
    SELECT DISTINCT
    ?ncbi_gene_id
    ?hgnc_gene_symbol
    ?rating
    ?source
    ?source_url
    ?nando_ja ?nando_en ?nando_id
    ?mondo_ja
    ?mondo_en
    ?mondo_sub_tier AS ?mondo_url
    ?nando_sub_tier
    ?reference_nando_id
    WHERE { 
      {
        SELECT DISTINCT ?nando_sub_tier ?mondo_sub_tier WHERE {
          VALUES ?nando_input { nando:{{nando_id_list}} }
          {
            # 하위 tier들의 MONDO
            ?nando_sub_tier rdfs:subClassOf* ?nando_input .
            FILTER (?nando_sub_tier != ?nando_input)
            ?nando_sub_tier skos:exactMatch ?mondo_exactMatch .
            ?mondo_sub_tier rdfs:subClassOf* ?mondo_exactMatch .
          }
          UNION
          {
            # 상위 tier만 가지는 고유한 MONDO
            ?nando_input skos:exactMatch ?mondo_exactMatch .
            ?mondo_sub_tier rdfs:subClassOf* ?mondo_exactMatch .

            FILTER NOT EXISTS {
              ?other_nando rdfs:subClassOf* ?nando_input .
              FILTER (?other_nando != ?nando_input)
              ?other_nando skos:exactMatch ?other_match .
              ?mondo_sub_tier rdfs:subClassOf* ?other_match .
            }
            BIND(?nando_input AS ?nando_sub_tier)
          }
        }
      }
      ?nando_sub_tier dcterms:identifier ?reference_nando_id .
      ?mondo_sub_tier skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "/omim.org/entry/") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      # edit start 260414
      #BIND(IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .
      BIND(IRI(REPLACE(STR(?exactMatch_disease), "http://identifiers.org/mim/|http://identifiers.org/omim/", "https://omim.org/entry/")) AS ?disease)
      # edit end 260414

      # add start 260303
      ?nando_sub_tier rdfs:label ?nando_ja ;
                      rdfs:label ?nando_en.
      FILTER(lang(?nando_ja) = "ja")
      FILTER(lang(?nando_en) = "en")
      FILTER(CONTAINS(STR(?nando_sub_tier), "NANDO_1"))
      # add end 260303

      OPTIONAL 
      {
        ?nando skos:exactMatch ?mondo_sub_tier ;
               dcterms:identifier ?nando_id .
        # del start 260303
        #           rdfs:label ?nando_ja ;
        #           rdfs:label ?nando_en.
        #    
        #    FILTER(lang(?nando_ja) = "ja")
        #    FILTER(lang(?nando_en) = "en")
        #    FILTER(CONTAINS(STR(?nando), "NANDO_1"))
        # del end 260303
      }
      # del start 260515
      #  FILTER (?reference_nando_id = ?nando_id || !BOUND(?nando_id))
      # del end 260515
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
  }
  #mode of inheritance
  OPTIONAL {
    ?source_url :hasInheritance ?inheritance .
    ?inheritance rdfs:label ?moi_en, ?moi_ja .
    FILTER (lang(?moi_en) = "" && lang(?moi_ja) = "ja") .
  }
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

    const nandoId = entry.reference_nando_id;

    if (!grouped[nandoId]) {
      grouped[nandoId] = [];
    }
    grouped[nandoId].push(entry);
  });

  return grouped;
}
```
