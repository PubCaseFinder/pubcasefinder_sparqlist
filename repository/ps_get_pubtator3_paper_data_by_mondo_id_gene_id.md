# [PCF] Get PubTator3 paper by MONDO ID NCBI GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0002708
  * example: 0005093, 0009903, 0007943, 0018096, 0007477
* `ncbi_gene_id` NCBI gene ID
  * default: 5458
  * example: 374, 7124, 10262, 55636

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql
//https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
  mondo_id = 'mondo:MONDO_' + mondo_id.replace(/[\s,]+/g," mondo:MONDO_")
  return mondo_id;
}
```

## `get_mesh_id` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?mesh_id
WHERE {
  VALUES ?mondo_list { {{mondo_id_list}} }
  #?mondo_sub_tier  rdfs:subClassOf* ?mondo_list .
  #?mondo_sub_tier skos:exactMatch ?mesh_id .
  ?mondo_list skos:exactMatch ?mesh_id .
  FILTER(CONTAINS(STR(?mesh_id), "mesh"))

}
```

## `mesh_id_list`
```javascript
({
  json({get_mesh_id}) {
    let headers = get_mesh_id.head.vars;
    let mesh_list = get_mesh_id.results.bindings.map((row) => {
      let obj = {};
      headers.forEach((column) => {
        obj[column] = (row[column] == null) ? "" : row[column].value.replace('http://identifiers.org/mesh/', '');
      });
      return obj;
    });
    return mesh_list.map((row) => { return "mesh:" + row["mesh_id"] }).join(" ");
  }
})
```

## Endpoint
http://plod01:7200/repositories/PubTatorCentral

## `news_ids` 
```sparql
PREFIX sio:       <http://semanticscience.org/resource/>
PREFIX ncbigene:  <http://identifiers.org/ncbigene/>
PREFIX mesh:      <http://identifiers.org/mesh/>
PREFIX schemaorg: <https://schema.org/>
PREFIX pubmed:    <http://rdf.ncbi.nlm.nih.gov/pubmed/>

SELECT DISTINCT ?news_id
WHERE {
  GRAPH <http://purl.jp/bio/10/rdfportal/20250817>
  #GRAPH <http://purl.jp/bio/10/rdfportal/20241227> 
        {
          VALUES ?mesh_list { {{mesh_id_list}} }
          ?rel sio:SIO_000132 ncbigene:{{ncbi_gene_id}} ;
          sio:SIO_000132 ?mesh_list ;
                         schemaorg:newsUpdatesAndGuidelines ?news_id .
        }
}
```

## `news_pubmed_values`
```javascript
({
  json({news_ids}) {
    const rows = news_ids?.results?.bindings ?? [];
    const pmids = new Set();
    for (const r of rows) {
      const v = r.news_id?.value || "";
      const id = v
        .replace("http://rdf.ncbi.nlm.nih.gov/pubmed/", "")
        .replace(/^pubmed:/, "");
      if (id) pmids.add(id);
    }
    const arr = Array.from(pmids);
    return arr.length ? arr.map(id => "pubmed:" + id).join(" ") : "";
  }
})
```

## `input` 
```sparql
#http://plod01:7200/repositories/pubtator3
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX mesh: <http://identifiers.org/mesh/>
PREFIX dcterms: <http://purl.org/dc/terms/>
SELECT DISTINCT ?pubmed_id
WHERE {
  #GRAPH <http://purl.jp/bio/10/pubtator3/20240527>
  GRAPH <http://purl.jp/bio/10/rdfportal/20250817>
  #GRAPH <http://purl.jp/bio/10/rdfportal/20241227>
        {
          VALUES ?mesh_list { {{mesh_id_list}} }
          OPTIONAL {
            ?an sio:SIO_000132 ncbigene:{{ncbi_gene_id}} ;
            sio:SIO_000132 ?mesh_list ;
                           dcterms:source ?pubmed_id .
          }
        }
}
```

## `pubmed_list`
```javascript
({
  json({input}) {
    let headers = input.head.vars;
    let pfam_list = input.results.bindings.map((row) => {
      let obj = {};
      headers.forEach((column) => {
        obj[column] = (row[column] == null) ? "" : row[column].value.replace('http://rdf.ncbi.nlm.nih.gov/pubmed/', '');
      });
      return obj;
    });
    return pfam_list.map((row) => { return "pubmed:" + row["pubmed_id"] }).join(" ");
  }
})
```
## Endpoint
https://rdfportal.org/backend/ncbi/sparql
//https://rdfportal.org/ncbi/sparql

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX pubmed: <http://rdf.ncbi.nlm.nih.gov/pubmed/>
PREFIX basic: <http://prismstandard.org/namespeces/1.2/basic/>
PREFIX schemaorg: <https://schema.org/>

SELECT DISTINCT ?title ?pubmed_id AS ?paper_url ?journal ?date "PubTator3" AS ?source ?new_association
{
  GRAPH <http://rdfportal.org/dataset/pubmed> {
    VALUES ?pubmed_id { {{pubmed_list}} }
    ?pubmed_id dcterms:title ?title ;
               basic:publicationName ?journal ;
               dcterms:issued ?date .
  }

  # news_pubmed_values 가 비어도 메인 결과는 유지됨
  OPTIONAL {
    VALUES ?news_id { {{news_pubmed_values}} }    # 여기 자리에 {{news_pubmed_values}} 들어감
    FILTER(SAMETERM(?news_id, ?pubmed_id))
    BIND("true" AS ?new_association)       # ← 일치하면 "true" 문자열 바인딩
  }
}
ORDER BY DESC(?date)
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