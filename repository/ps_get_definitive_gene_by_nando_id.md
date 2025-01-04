# [PCF] FILTER: GET Definitive GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
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
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
SELECT 
?ncbi_gene_id
?hgnc_gene_symbol
"Definitive" AS ?rating
"指定難病の遺伝学的検査に関するガイドライン" AS ?source
"https://jshg.jp/wp-content/uploads/2024/03/a02edeee573e7797da6a821a5bc48026.pdf" AS ?source_url
?nando_ja
?nando_en
#?nando_label_ja
#?nando_label_en
?nando_id
WHERE {
  VALUES ?nando { nando:{{nando_id_list}} }
  ?an sio:SIO_000628 ?nando ;
      sio:SIO_000628 ?ncbi_gene_url .
      #dcterms:source ?source .
  ?ncbi_gene_url rdf:type ncit:C16612 ;
                 dcterms:identifier ?ncbi_gene_id ;
                 sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  ?nando rdfs:label ?nando_ja ;
         rdfs:label ?nando_en ;
         dcterms:identifier ?nando_id .
  FILTER(lang(?nando_ja) = "ja")
  FILTER(lang(?nando_en) = "en")
  #BIND(CONCAT(?nando_ja, ", ", ?nando_id) AS ?nando_ja)
  #BIND(CONCAT(?nando_en, ", ", ?nando_id) AS ?nando_en)
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