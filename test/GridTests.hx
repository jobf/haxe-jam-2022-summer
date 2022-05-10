package test;

import tyke.Grid;
import utest.Test;
import utest.Assert;

class GridTests extends Test{
    function test_total_cell_count(){
        var numRows = 10;
        var numColumns = 10;
        var grid = new GridStructure<Int>(numRows, numColumns, (c, r) -> 0);
        var totalCells = 100;
        Assert.same(totalCells, grid.cells.length);
    }

    function test_section_total_cell_count(){
        var numRows = 10;
        var numColumns = 10;
        var grid = new GridStructure<Int>(numRows, numColumns, (c, r) -> 0);
        var section = grid.indexesInSection(5, 5, 5, 5);
        var totalCells = 25;
        Assert.same(totalCells, section.length);
    }
    
    function test_section_indexes_are_correct(){
        var numRows = 4;
        var numColumns = 4;
        var grid = new GridStructure<Int>(numRows, numColumns, (c, r) -> 0);
        var section = grid.indexesInSection(1, 1, 3, 3);
        var expected = [5, 6, 7, 9, 10, 11, 13, 14, 15];
        Assert.same(expected, section);
    }

}
