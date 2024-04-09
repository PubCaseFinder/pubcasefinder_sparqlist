# Get variant data in ClinVar

## Parameters

* `nando_id` NANDO ID
  * default: 1200030
  * examples: 1200061
  
## Endpoint
https://togodx.dbcls.jp/human/sparql

## `nando2mondo2medgen`
```sparql
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mo: <http://med2rdf/ontology/medgen#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?mondo ?medgen_id ?medgen_cid 
WHERE {
  GRAPH <http://rdf.integbio.jp/dataset/togosite/nando>{ 
      nando:{{nando_id}} skos:closeMatch ?mondo .
    }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/medgen>{ 
    ?medgen_uri
    dct:identifier ?medgen ;
    mo:mgconso ?mgconso .
    ?mgconso
    dct:source mo:MONDO ;
    rdfs:seeAlso ?mondo.
    BIND (CONCAT("http://ncbi.nlm.nih.gov/medgen/",?medgen)AS ?medgen_id)
    BIND (IRI(?medgen_id)AS ?medgen_cid)
    }
}
 ```
 ## `medgen`
 ```javascript
({nando2mondo2medgen}) => {
  return nando2mondo2medgen.results.bindings.map(b => b.medgen_cid.value);
}

```
## Endpoint
https://grch38.togovar.org/sparql

## `medgen2clinvar2togovar`
```sparql
PREFIX cvo:    <http://purl.jp/bio/10/clinvar/>
PREFIX dct:    <http://purl.org/dc/terms/>
PREFIX medgen: <http://ncbi.nlm.nih.gov/medgen/>
PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio:    <http://semanticscience.org/resource/>
PREFIX tgvo:   <http://togovar.biosciencedbc.jp/vocabulary/>

SELECT DISTINCT ?tgv_id ?rs_id ?variant ?title ?condition ?clinvar ?vcv ?type ?med_id ?interpretation
WHERE {
  VALUES ?med_id { {{#each medgen}} <{{this}}> {{/each}} } 

  GRAPH <http://togovar.org/clinvar> {
    ?med_id ^dct:references ?_interpreted_condition .

    ?_interpreted_condition rdfs:label ?condition ;
      ^cvo:interpreted_condition/^cvo:interpreted_condition_list ?_rcv .

    ?_rcv dct:identifier ?rcv ;
      cvo:date_last_evaluated ?last_evaluated ;
      cvo:interpretation ?interpretation ;
      ^cvo:rcv_accession/^cvo:rcv_list/^cvo:interpreted_record ?clinvar .

    ?clinvar a cvo:VariationArchiveType ;
      rdfs:label ?title ;
      cvo:accession ?vcv ;
      cvo:variation_id ?vid .
     # cvo:interpreted_record/cvo:review_status ?review_status ;
     # cvo:interpreted_record/sio:SIO_000628/dct:references ?dbsnp .

    BIND(STR(?vid) AS ?variation_id)

    # ?dbsnp rdfs:seeAlso ?rs_id ;
    #  dct:source ?dbname .
    # FILTER(?dbname IN ("dbSNP"))
  }

   GRAPH <http://togovar.org/variant/annotation/clinvar> {
    ?variant dct:identifier ?variation_id .
   }

  GRAPH <http://togovar.org/variant> {
    ?variant dct:identifier ?tgv_id ;
             rdf:type ?type.
  }
}
                    
```
## result
```javascript
({medgen2clinvar2togovar, nando2mondo2medgen}) => {
    const medgen2mondo = {};
    nando2mondo2medgen.results.bindings.forEach(x => {
      medgen2mondo[x.medgen_id.value] = x.mondo.value;
                });
    return medgen2clinvar2togovar.results.bindings.map(x => {
    const position = x.variant.value.match(/http:\/\/identifiers.org\/hco\/(.+)\/GRCh3[78]#(\d+)/);

    return {
      tgv_id: x.tgv_id.value,
      tgv_link: "https://grch38.togovar.org/variant/" + x.tgv_id.value,
      position: position[1] + ":" + position[2],
      title: x.title.value,
      Clinvar_link: x.clinvar.value,
      Clinvar_id: x. vcv.value,
      Interpretation: x. interpretation. value,
      type: x.type.value.replace("http://genome-variation.org/resource#",""),
      MedGen_id: x.med_id.value.replace("http://ncbi.nlm.nih.gov/medgen/",""),
      MedGen_link:x.med_id.value,
      mondo: medgen2mondo[x.med_id.value],
      mondo_id: medgen2mondo[x.med_id.value].replace("http://purl.obolibrary.org/obo/MONDO_","MONDO:")
      
      
    };
  });
}
```
## Description
- NanbyoDataでヴァリアントの情報を表示させるために利用しているSPARQListです。
- Togovarのエンドポイントを利用しています。
- SPARQListの大元はTogovarから頂いています。
- NANDOからMONDO,MONDOからMedGenのIDに変更して、Clinvarのデータを取得しています。
- 編集：高月（2024/01/12)