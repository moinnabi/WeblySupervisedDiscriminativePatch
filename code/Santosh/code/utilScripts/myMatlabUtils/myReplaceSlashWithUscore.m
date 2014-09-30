function this_string = myReplaceSlashWithUscore(this_string)

this_string(find(this_string == '/')) = '_';
