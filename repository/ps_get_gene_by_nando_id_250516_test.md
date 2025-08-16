# [PCF] FILTER: GET GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200477
  * example: 1200478, 1200483, 1200009, 2200865

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
?reference_nando_id
WHERE {
# Start 20250110
  {
    OPTIONAL {
      VALUES ?nando_input { {{#each nando_id_list}} nando:{{this}} {{/each}} }
      ?as sio:SIO_000628 ?nando_input ;
          sio:SIO_000628 ?gene ;
          dcterms:source ?source .
      ?nando_input a owl:Class ;
                     dcterms:identifier ?disease_id, ?reference_nando_id;
                     rdfs:label ?disease_name,?disease_name_ja .
      ?gene rdf:type ncit:C16612 ;
            sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] ;
            dcterms:identifier ?gene_id .

      BIND(CONCAT(?disease_name_ja, ", ", ?disease_id) AS ?disease_info_ja)
      BIND(CONCAT(?disease_name, ", ", ?disease_id) AS ?disease_info)
      FILTER (lang(?disease_name_ja) = "ja")
      FILTER(lang(?disease_name) = "en")
      
        #BIND( LANG("ガイドライン") AS ?source_name).
      #BIND(IF(STR(?source) = 'http://www.gene-dt.jp/pdf/guideline_did2403_list.pdf', "指定難病の遺伝学的検査に関するガイドライン", '') AS ?source_name)
      BIND(replace(STR(?source), "http://www.gene-dt.jp/pdf/guideline_did2403_list.pdf", "Guideline") AS ?source_name) .
    }
  }
  UNION
  {
# End 20250110    
    {
    SELECT DISTINCT ?nando_sub_tier ?mondo_sub_tier WHERE {
      VALUES ?nando_input { {{#each nando_id_list}} nando:{{this}} {{/each}} }
      {
        # 하위 tier들의 MONDO
        #?nando_sub_tier rdfs:subClassOf* ?nando_input .
        OPTIONAL {?nando_sub_tier nando:memberOf | rdfs:subClassOf* ?nando_input . }
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
          #?other_nando rdfs:subClassOf* ?nando_input .
          OPTIONAL {?other_nando nando:memberOf | rdfs:subClassOf* ?nando_input . }
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
  BIND(IRI(replace(STR(?exactMatch_disease), 'https://omim.org/entry/', 'http://identifiers.org/mim/')) AS ?disease) .

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
# Start 20250110
  }
# End 20250110
} order by ?hgnc_gene_symbol
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
