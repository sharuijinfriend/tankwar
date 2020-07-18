for i in range(240,200,-10):
    print('( (bullet_x[%s+:10]>=tank_x[20+:10])&&((bullet_x[%s+:10])<tank_x[20+:10]+10\'d30 )&& (bullet_y[%s+:10]>=tank_y[20+:10])&&((bullet_y[%s+:10])<tank_y[20+:10]+10\'d30 ) && bullet_exit[%s]) ||'%(i,i,i,i,int(i/10)))
    # print('(((bullet_x>=other_bullet_x[%s:%s] &&(bullet_x-other_bullet_x[%s:%s])<10\'d2)||(bullet_x<other_bullet_x[%s:%s] &&(other_bullet_x[%s:%s]-bullet_x)<10\'d2)) && (((bullet_x>=other_bullet_x[%s:%s] &&(bullet_x-other_bullet_x[%s:%s])<10\'d2)||(bullet_x<other_bullet_x[%s:%s] &&(other_bullet_x[%s:%s]-bullet_x)<10\'d2))))||'%(10*i+9,10*i,10*i+9,10*i),end='\n',sep='')
    # print('( (  (bullet_x>=other_bullet_x[%s:%s] &&(bullet_x-other_bullet_x[%s:%s])<10\'d2)||(bullet_x<other_bullet_x[%s:%s] &&(other_bullet_x[%s:%s]-bullet_x)<10\'d2) )&&( (bullet_y>=other_bullet_y[%s:%s] &&(bullet_y-other_bullet_y[%s:%s])<10\'d2)|| (bullet_y<other_bullet_y[%s:%s] &&(other_bullet_y[%s:%s]-bullet_y)<10\'d2)))||'%(10*i+9,10*i,10*i+9,10*i,10*i+9,10*i,10*i+9,10*i,10*i+9,10*i,10*i+9,10*i,10*i+9,10*i,10*i+9,10*i),end='\n',sep='')
        # (bullet_x>=other_bullet_x[%s:%s] &&(bullet_x-other_bullet_x[%s:%s])<10\'d2)
        # (bullet_x<other_bullet_x[%s:%s] &&(other_bullet_x[%s:%s]-bullet_x)<10\'d2)
        # (bullet_y>=other_bullet_y[%s:%s] &&(bullet_y-other_bullet_y[%s:%s])<10\'d2)
        # (bullet_y<other_bullet_y[%s:%s] &&(other_bullet_y[%s:%s]-bullet_y)<10\'d2)
        
    # print('else if( ( (tank_x[49:40]-10\'d1-tank_x[30+:10])<10\'d30 && ( ||) ) ||( (tank_x[49:40]-10\'d1-tank_x[20+:10])<10\'d30 && tank_y[49:40]==tank_y[20+:10] ))')
# for i in range(140,100,-10):
        # print('( (bullet_x[%s+:10]>=tank_x[40+:10])&&((bullet_x[%s+:10])<tank_x[40+:10]+10\'d30 )&& (bullet_y[%s+:10]>=tank_y[40+:10])&&((bullet_y[%s+:10])<tank_y[40+:10]+10\'d30 ) && bullet_exit[%s]) ||'%(i,i,i,i,int(i/10)))
for j in range (5,-1,-1):
    print('seg%s_ori=score/20\'d1e%s;'%(j,j))
    
for j in range (5,-1,-1):
    print('assign seg%s=seg%s_tem;'%(j,j))
    # -seg%s_ori*4\'d1e%s