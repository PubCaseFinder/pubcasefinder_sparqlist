# [PCF] Get OMIM data by OMIM ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `omim_id` OMIM ID (複数のIDを入力可能)
  * default: OMIM:181500,OMIM:214800,OMIM:263750,OMIM:219000
  * example: 263750, 154400, 214800, 105650, 609945, 219000, 143095, 615162, 122470, 115470, 230400, 182280263750, 154400, 214800, 105650, 609945, 219000, 143095, 615162, 122470, 115470, 613172, 613174, 609909, 145250, 146580, 613177, 613179, 184850, 205400, 601195 
* `mode` (パラメータに"download"を入力すると全件取得可能)
	* example: download

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `omim_id_list`
```javascript
({omim_id}) => {
  omim_id = omim_id.replace(/OMIM:/g,"")
  omim_id = 'mim:' + omim_id.replace(/[\s,]+/g," mim:")
  return omim_id;
}
```

## `result` 
```sparql
#268300 ?mondo rdfs:label ?disease_name . 문제 해결해야됨
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nando: <http://nanbyodata.jp/ontology/nando#>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX owl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT
str(?disease_name_en) as ?omim_disease_name_en
str(?disease_name_ja) as ?omim_disease_name_ja
str(?gene_ID) as ?ncbi_gene_id
str(?gene_symbol) as ?hgnc_gene_symbol
str(?inheritance_name_en) as ?inheritance_en
str(?inheritance_name_ja) as ?inheritance_ja
str(?inheritance_id_en) as ?inheritance_id_en
str(?inheritance_id_ja) as ?inheritance_id_ja
CONCAT('OMIM:', STR(?omim_id)) as ?omim_id
str(?mim_id) as ?omim_url
str(?mondo_ID) as ?mondo_id
?mondo_url
str(?DBMS) as ?ur_dbms_url
str(?kegg) as ?kegg_url
str(?gene_reviews) as ?gene_reviews_url
str(?gtr) as ?gtr_url
str(?description) as ?description
str(?nando_url) as ?nando_url
?hpo as ?count_hpo_id
#CONCAT('ORPHA:', STR(?orpha_id)) as ?orpha_id
str(?orpha_id) as ?orpha_id
str(?orpha_url) as ?orpha_url
str(?hpo_id) as ?hpo_id
str(?hpo_url) as ?hpo_url

WHERE {
  {{#if mode}}
    {
      SELECT DISTINCT ?mim_id count(DISTINCT ?hpo) as ?hpo WHERE {        
        ?an rdf:type oa:Annotation ;
            oa:hasTarget ?mim_id ;
            oa:hasBody ?hpo ;
            dcterms:source [dcterms:creator ?creator] .
        FILTER(CONTAINS(STR(?mim_id), "mim"))
        FILTER(?creator NOT IN("Database Center for Life Science"))
        GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
          ?hpo rdfs:subClassOf+ ?hpo_category .
          ?hpo_category rdfs:subClassOf obo:HP_0000118 .
        }
      }
    }
  {{else}}
    {{#if omim_id_list}}
      VALUES ?mim_id { {{omim_id_list}} }
      {
        SELECT DISTINCT ?mim_id count(DISTINCT ?hpo) as ?hpo WHERE {
          ?an rdf:type oa:Annotation ;
              oa:hasTarget ?mim_id ;
              oa:hasBody ?hpo ;
              dcterms:source [dcterms:creator ?creator] .
          FILTER(CONTAINS(STR(?mim_id), "mim"))
          FILTER(?creator NOT IN("Database Center for Life Science"))
          GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
            ?hpo rdfs:subClassOf+ ?hpo_category .
            ?hpo_category rdfs:subClassOf obo:HP_0000118 .
          }
        }
       }
    {{/if}}
  {{/if}}
      OPTIONAL { 
        ?mim_id nando:hasInheritance ?inheritance_en .
        ?mim_id nando:hasInheritance ?inheritance_ja .
        ?inheritance_en rdfs:label ?inheritance_name_en .
        ?inheritance_ja rdfs:label ?inheritance_name_ja .
        BIND (replace(str(?inheritance_en), 'http://purl.obolibrary.org/obo/HP_', 'HP:') AS ?inheritance_id_en)
        BIND (replace(str(?inheritance_ja), 'http://purl.obolibrary.org/obo/HP_', 'HP:') AS ?inheritance_id_ja)
        FILTER (lang(?inheritance_name_en) = "en")
        FILTER (lang(?inheritance_name_ja) = "ja")
      }

      OPTIONAL { ?mim_id rdfs:seeAlso ?DBMS  FILTER(CONTAINS(STR(?DBMS), "UR-DBMS")) }
      OPTIONAL { ?mim_id rdfs:seeAlso ?kegg  FILTER(CONTAINS(STR(?kegg), "kegg")) }
      OPTIONAL { ?mim_id rdfs:seeAlso ?gene_reviews  FILTER(CONTAINS(STR(?gene_reviews), "books")) }
      OPTIONAL { ?mim_id rdfs:seeAlso ?gtr  FILTER(CONTAINS(STR(?gtr), "gtr")) }

      #mondo id, disease name, description
      OPTIONAL { ?mim_id rdfs:label ?disease_name_ja FILTER (lang(?disease_name_ja) = "ja") }
      OPTIONAL { ?mim_id rdfs:seeAlso ?mondo . BIND (replace(str(?mondo), 'http://purl.obolibrary.org/obo/MONDO_', 'https://monarchinitiative.org/disease/MONDO:') AS ?mondo_url) }
      
      ?mondo rdfs:label ?disease_name_en .
      OPTIONAL { ?mondo <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_ID . }
      OPTIONAL { ?mondo obo:IAO_0000115 ?description . }
      
      OPTIONAL { ?mondo owl:hasDbXref ?hpo_id  FILTER(CONTAINS(STR(?hpo_id), "HP")) }
      BIND (replace(str(?hpo_id), 'HP:', 'http://purl.obolibrary.org/obo/HP_') AS ?hpo_url)      
      
      #nando url
      OPTIONAL {
        GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/nando>{
          ?nando_url skos:closeMatch ?mondo.
        }
      }
      #gene id, gene symbol
      OPTIONAL {
        ?as sio:SIO_000628 ?mim_id ;
            sio:SIO_000628 ?gene .
        ?mim_id rdf:type ncit:C7057 .
        ?gene rdf:type ncit:C16612 ;
              dcterms:identifier ?gene_ID ;
              sio:SIO_000205 ?HGNC .
        ?HGNC rdfs:label ?gene_symbol .
      }

      BIND (replace(str(?mim_id), 'http://identifiers.org/mim/', '') AS ?omim_id)
      
      OPTIONAL { ?ordo_id rdfs:seeAlso ?mondo FILTER(CONTAINS(STR(?ordo_id), "ORDO")) }
      BIND (replace(str(?ordo_id), 'http://www.orpha.net/ORDO/Orphanet_', 'ORPHA:') AS ?orpha_id)
      BIND (CONCAT('https://www.orpha.net/en/disease/detail/', ?orpha_id, '?name=', ?orpha_id, '&mode=orpha') AS ?orpha_url)
      
}
```

## Output
```javascript
({ result }) => {
  const rows = result.results.bindings;
  const dic = {}
  const itemTemplate = {
    omim_url: "",
    omim_disease_name_en: "",
    omim_disease_name_ja: "",
    description: "",
    ur_dbms_url: "",
    count_hpo_id: "",
    ncbi_gene_id: [],
    hgnc_gene_symbol: [],
    inheritance_en: {},
    inheritance_ja: {},
    mondo_id: [],
    mondo_url: [],
    nando_url: [],
    kegg_url: [],
    gene_reviews_url: [],
    gtr_url: [],
    orpha_id: [],
    orpha_url: [],
    hpo_id: [],
    hpo_url: []
  }

  const prefixList = {
    ncbi_gene_id: "GENEID:",
  }

  const objKeyMapping = {
    inheritance_en: 'inheritance_id_en',
    inheritance_ja: 'inheritance_id_ja'
  }

  rows.forEach(row => {
    const omimId = row.omim_id.value
    if (!dic[omimId]) dic[omimId] = {}
    Object.keys(itemTemplate).forEach(k => {
      const value = prefixList[k] && row[k] ? `${prefixList[k]}${row[k]?.value}` : row[k]?.value
      if (!value) return
      if (typeof itemTemplate[k] === 'string') {
        dic[omimId][k] = value
      } else if (Array.isArray(itemTemplate[k]) && !dic[omimId][k]?.includes(value)) {
        if (!dic[omimId][k]) {
          dic[omimId][k] = [value]
          return
        }
        dic[omimId][k] = [...dic[omimId][k], value]
      } else if (typeof itemTemplate[k] === 'object' && itemTemplate[k] !== null) {
        if (!dic[omimId][k]) {
          dic[omimId][k] = { [row[objKeyMapping[k]]?.value]: value }
          return
        }
        dic[omimId][k][row[objKeyMapping[k]]?.value] = value
      }
    })
  })

  return dic
};
```