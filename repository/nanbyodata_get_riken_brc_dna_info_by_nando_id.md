# Get RIKEN BRC DNA data

## Parameters

* `nando_id` NANDO ID
  * default: 2200053 

## Endpoint

https://knowledge.brc.riken.jp/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dct:  <http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX brso: <http://purl.jp/bio/10/brso/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT ?dna STR(?label) AS ?gene_label ?hp STR(?id)AS ?gene_id ?ncbi_gene ?gene ?nando
WHERE{
  VALUES ?nando { nando:{{nando_id}} }
  graph <http://metadb.riken.jp/db/dna_diseaseID>{
    ?dna <http://purl.obolibrary.org/obo/RO_0003301> ?nando.}
  graph <http://metadb.riken.jp/db/xsearch_dnabank_brso>{
    ?dna rdfs:label ?label;
         foaf:homepage ?hp;
         dct:identifier ?id;
         brso:genomic_feature ?B.
    ?B   brso:has_genomic_segment ?B1.
    ?B1  rdfs:seeAlso ?ncbi_gene;
         skos:altLabel ?gene.}
  FILTER(STRSTARTS(STR(?ncbi_gene), "http://identifiers.org/ncbigene/"))
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

## Description
- NanbyoDataで理研の遺伝子材料の情報を表示させるために利用しているSPARQListです。
- 理研のエンドポイントを利用しています。
- 編集：高月（2024/01/12)