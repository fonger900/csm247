from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import aliased
from sqlalchemy import *
 
#~needed package~
#pip install sqlalchemy
#sudo apt-get install python-mysqldb

#engine = create_engine('mysql://phong_r:phong@192.168.247.129:3306/test', echo=True)
engine = create_engine('mysql://root:root@localhost:3306/test', echo=True)
Base = declarative_base(engine)
demo_user = [  '85.25.214.38'
, '85.25.119.91'
, '85.25.109.116'
, '85.25.100.223'
, '85.214.57.21'
, '85.214.250.21'
, '85.214.248.47'
, '85.13.204.33'
, '85.119.65.110'
, '85.111.74.40'
, '83.52.16.219'
]

ctyB = [
 '88.101.42.67'
, '87.236.207.63'
, '87.207.45.28'
, '87.181.96.199'
, '87.148.180.33'
, '87.116.148.184'
, '87.106.53.186'
, '87.106.149.74'
, '86.97.27.3'
]
########################################################################
class Incident(Base):
	""""""
	__tablename__ = 'incident'
	__table_args__ = {'autoload':True}
 
#----------------------------------------------------------------------
class Incident_alarm(Base):
	""""""
	__tablename__ = 'incident_alarm'
	__table_args__ = {'autoload':True}

#----------------------------------------------------------------------
def loadSession():
	""""""
	metadata = Base.metadata
	Session = sessionmaker(bind=engine)
	session = Session()
	return session
 
if __name__ == "__main__":
	session = loadSession()
	#incident = session.query(Incident).all()
	# ticket_id = Incident.id.label('ticket_id')
	# host = Incident_alarm.dst_ips.label('host')
	# alarm = session.query(ticket_id,host).\
	# 	filter(Incident.id==Incident_alarm.incident_id).\
	# 	all()

	for i in demo_user:
		session.query(Incident).filter(and_(Incident.id==Incident_alarm.incident_id , Incident_alarm.dst_ips==i)).update({ 'in_charge' : 'demo'},synchronize_session=False)

	for i in ctyB:
		session.query(Incident).filter(and_(Incident.id==Incident_alarm.incident_id , Incident_alarm.dst_ips==i)).update({ 'in_charge' : 'ctyB'},synchronize_session=False)

	session.commit()
