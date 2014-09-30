function object=myPASemptyobject

object.label='';
object.orglabel='';
object.bbox=[];
object.polygon=[];
object.mask='';
object.difficult=false;
return

%{
  object.label='';
  object.orglabel='';
  object.bbox=[];
  object.polygon=[];
  object.mask='';
  object.class='';
  object.view='';
  object.truncated=false;
  object.difficult=false;

%}
