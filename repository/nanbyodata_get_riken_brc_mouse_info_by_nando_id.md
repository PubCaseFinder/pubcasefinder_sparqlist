# Get RIKEN BRC mouse data

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

select ?mouse STR(?name) AS ?mouse_name ?hp STR(?id) AS ?mouse_id ?description ?nando
where{
  VALUES ?nando { nando:{{nando_id}} }
  graph <http://metadb.riken.jp/db/mouse_diseaseID>{
    ?mouse <http://purl.obolibrary.org/obo/RO_0003301> ?nando.}
  graph <http://metadb.riken.jp/db/xsearch_animal_brso>{
    ?mouse rdfs:label ?name;
           foaf:homepage ?hp;
           dct:identifier ?id.
      OPTIONAL {?mouse dc:description ?description.}
      FILTER (lang(?description) = "ja")
      }
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
- NanbyoDataで理研のマウスの情報を表示させるために利用しているSPARQListです。
- 理研のエンドポイントを利用しています。
- 編集：高月（2024/01/12)